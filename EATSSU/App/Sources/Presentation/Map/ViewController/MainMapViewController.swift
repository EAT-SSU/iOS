//
//  MainMapViewController.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 6/24/25.
//

import UIKit
import CoreLocation

import NMapsMap
import Moya

import EATSSUDesign

final class MainMapViewController: BaseViewController {

    // MARK: - Constants

    /// 지도 초기 카메라 위치 설정값
    private enum CameraConstants {
        /// 숭실대입구역과 숭실대학교 사이 (역에서 살짝 동쪽)
        static let initialLatitude = 37.4960
        static let initialLongitude = 126.9555
        static let initialZoom: Double = 14.7
        static let animationDuration: TimeInterval = 0.3
    }

    /// 화면 진입 형태
    enum Mode {
        /// 탭바 안의 지도 탭: 상단에 학교 제휴 / 착한 가격 탭 노출
        case tabbed
        /// 로그인 화면에서 바로 진입하는 착한가격업소 지도 (탭 없음)
        case standaloneGoodPrice
    }

    // MARK: - Properties

    let mode: Mode
    let root = MainMapView()
    let locationManager = CLLocationManager()
    var currentDepartmentName: String?
    var currentDepartmentId: Int?
    var currentCollegeId: Int?
    var hasRequestedLocationPermission = false

    var clusterer: NMCClusterer<MapMarkerKey>?

    /// 가장 최근에 받아온 전체 제휴 목록 (축제 필터용 캐시)
    var cachedAllPartnerships: [PartnershipDTO] = []
    /// 착한가격업소 전체 목록 캐시 (카테고리 필터링용)
    var cachedGoodPriceStores: [GoodPriceStoreDTO] = []

    /// 탭/필터가 바뀔 때마다 증가. 늦게 도착한 응답이 현재 화면을 덮어쓰지 않도록 완료 시점에 비교
    private(set) var loadGeneration = 0

    /// 새 로드 시작을 알리고 해당 로드의 세대 번호를 반환
    func beginLoad() -> Int {
        loadGeneration += 1
        return loadGeneration
    }

    /// 해당 세대의 응답이 아직 유효한지
    func isCurrentLoad(_ generation: Int) -> Bool {
        generation == loadGeneration
    }

    /// 학과 조회 상태. 조회가 끝나기 전에 필터를 탭해도 "학과 없음"으로 오판하지 않도록 구분
    private enum DepartmentLoadState {
        case idle, loading, loaded
    }
    private var departmentLoadState: DepartmentLoadState = .idle

    /// 현재 칩 바에 그려진 필터 목록. 탭 시 Remote Config를 다시 읽지 않고 이 스냅샷의 인덱스를 사용
    private var displayedPartnershipFilters: [PartnershipFilter] = []

    // MARK: - State

    private(set) var currentTab: MapTab
    private(set) var partnershipFilter: PartnershipFilter = .all
    private(set) var goodPriceCategory: GoodPriceCategory = .all

    /// 현재 노출 중인 학교 제휴 필터 목록 (축제 활성 여부에 따라 달라짐)
    private var visiblePartnershipFilters: [PartnershipFilter] {
        let festivalEnabled = FirebaseRemoteConfig.shared.isFestivalEnabled
        return PartnershipFilter.allCases.filter { $0 != .festival || festivalEnabled }
    }

    /// 클러스터 색상: 축제 필터일 때만 축제 색
    var clusterColor: UIColor {
        (currentTab == .partnership && partnershipFilter == .festival) ? .festivalPrimary : .primary
    }

    // MARK: - Init

    init(mode: Mode = .tabbed) {
        self.mode = mode
        self.currentTab = (mode == .standaloneGoodPrice) ? .goodPrice : .partnership
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Setup

    override func configureUI() {
        view.addSubview(root)
        root.setTopTabVisible(mode == .tabbed)
    }

    override func setLayout() {
        root.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    override func setButtonEvent() {
        root.topTabView.onSelect = { [weak self] index in
            guard let tab = MapTab(rawValue: index) else { return }
            self?.switchTab(to: tab)
        }
        root.filterChipBar.onSelect = { [weak self] index in
            self?.didSelectFilter(at: index)
        }
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self

        configureNavigationBar()
        setInitialCameraPosition(animated: false)
        setupLocationButtonObserver()
        setupMarkerTapHandler()
        applyTabUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logScreenView(screenID: FirebaseScreenID.Map.map1)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        switch currentTab {
        case .partnership:
            refreshPartnershipTab()
        case .goodPrice:
            loadGoodPriceMarkers()
        }
    }

    /// 학과 정보를 다시 받아온 뒤 학교 제휴 마커 로드. 축제 노출 여부가 바뀌었을 수 있어 칩도 재구성
    private func refreshPartnershipTab() {
        applyTabUI()
        let generation = beginLoad()
        departmentLoadState = .loading
        fetchDepartment { [weak self] in
            guard let self else { return }
            self.departmentLoadState = .loaded
            guard self.isCurrentLoad(generation) else { return }
            self.loadPartnershipMarkers()
        }
    }

    // MARK: - Configuration

    private func configureNavigationBar() {
        title = (mode == .standaloneGoodPrice) ? TextLiteral.Map.goodPriceMapTitle : TextLiteral.Map.map
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = .white
        navBarAppearance.shadowColor = .clear
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: EATSSUDesignFontFamily.Pretendard.bold.font(size: 16)
        ]
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController?.navigationBar.compactAppearance = navBarAppearance
        navigationController?.navigationBar.tintColor = .black
        navigationItem.backButtonDisplayMode = .minimal

        // 모달로 띄워진 단독 화면이면 닫기 버튼 제공
        if mode == .standaloneGoodPrice,
           presentingViewController != nil,
           navigationController?.viewControllers.first === self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: EATSSUDesignAsset.Images.icClose.image.resize(newWidth: 24),
                style: .plain,
                target: self,
                action: #selector(didTapClose)
            )
        }
    }

    @objc private func didTapClose() {
        dismiss(animated: true)
    }

    /// 현재 탭에 맞춰 필터 칩과 선택 상태를 갱신
    private func applyTabUI() {
        root.topTabView.select(index: currentTab.rawValue, animated: false)

        switch currentTab {
        case .partnership:
            let filters = visiblePartnershipFilters
            if !filters.contains(partnershipFilter) { partnershipFilter = .all }
            displayedPartnershipFilters = filters
            root.filterChipBar.highlightColor = clusterColor
            root.filterChipBar.configure(
                titles: filters.map { $0.title },
                selectedIndex: filters.firstIndex(of: partnershipFilter) ?? 0
            )
        case .goodPrice:
            root.filterChipBar.highlightColor = .primary
            root.filterChipBar.configure(
                titles: GoodPriceCategory.allCases.map { $0.title },
                selectedIndex: GoodPriceCategory.allCases.firstIndex(of: goodPriceCategory) ?? 0
            )
        }
    }

    // MARK: - Tab & Filter Actions

    private func switchTab(to tab: MapTab) {
        guard currentTab != tab else { return }
        currentTab = tab
        setInitialCameraPosition(animated: true)

        switch tab {
        case .partnership:
            refreshPartnershipTab()
        case .goodPrice:
            applyTabUI()
            MapAnalyticsManager.shared.logClickMapGoodPrice(
                collegeId: currentCollegeId,
                majorId: currentDepartmentId
            )
            loadGoodPriceMarkers()
        }
    }

    private func didSelectFilter(at index: Int) {
        switch currentTab {
        case .partnership:
            let filters = displayedPartnershipFilters
            guard filters.indices.contains(index) else { return }
            partnershipFilter = filters[index]
            root.filterChipBar.highlightColor = clusterColor
            logPartnershipFilterClick(partnershipFilter)
            loadPartnershipMarkers()

        case .goodPrice:
            let categories = GoodPriceCategory.allCases
            guard categories.indices.contains(index) else { return }
            goodPriceCategory = categories[index]
            MapAnalyticsManager.shared.logClickGoodPriceCategory(category: goodPriceCategory)
            loadGoodPriceMarkers()
        }

        // 필터가 바뀌면 캠퍼스 주변으로 되돌려 새 마커가 바로 보이게 한다 (필터 전환 전 동작과 동일)
        setInitialCameraPosition(animated: true)
    }

    /// 축제 → click_map_festival, 그 외(내 학과 제휴 기준) → 학과 있으면 click_map_mine, 없으면 click_map_all
    private func logPartnershipFilterClick(_ filter: PartnershipFilter) {
        switch filter {
        case .festival:
            MapAnalyticsManager.shared.logClickMapFestival(
                collegeId: currentCollegeId,
                majorId: currentDepartmentId
            )
        case .all, .restaurant, .cafe, .pub:
            if let collegeId = currentCollegeId, let majorId = currentDepartmentId {
                MapAnalyticsManager.shared.logClickMapMine(collegeId: collegeId, majorId: majorId)
            } else {
                MapAnalyticsManager.shared.logClickMapAll(
                    collegeId: currentCollegeId,
                    majorId: currentDepartmentId
                )
            }
        }
    }

    // MARK: - Partnership Tab

    /// 학교 제휴 탭 마커 로드. 학과 미입력이면 학과 입력 시트를 띄우고 마커는 비움
    func loadPartnershipMarkers() {
        if partnershipFilter == .festival {
            refreshAllPartnerships()
            return
        }

        guard hasDepartment else {
            switch departmentLoadState {
            case .loading:
                // 조회가 끝나면 refreshPartnershipTab 완료 블록이 현재 필터로 이어서 로드한다
                return
            case .idle:
                refreshPartnershipTab()
                return
            case .loaded:
                displayMarkers([])
                presentNoDepartmentSheetIfNeeded()
                return
            }
        }
        fetchMyPartnerships()
    }

    var hasDepartment: Bool {
        !(currentDepartmentName?.isEmpty ?? true)
    }

    private func presentNoDepartmentSheetIfNeeded() {
        guard mode == .tabbed, currentTab == .partnership, presentedViewController == nil else { return }
        present(NoDepartmentSheetViewController(), animated: true)
    }

    // MARK: - Helper Methods

    /// 탭바에서 지도 탭을 다시 눌렀을 때 현재 탭 데이터 갱신
    func reloadContent() {
        switch currentTab {
        case .partnership:
            cachedAllPartnerships = []
            refreshPartnershipTab()
        case .goodPrice:
            cachedGoodPriceStores = []
            loadGoodPriceMarkers()
        }
    }

    func setInitialCameraPosition(animated: Bool) {
        let cameraUpdate = NMFCameraUpdate(
            scrollTo: NMGLatLng(
                lat: CameraConstants.initialLatitude,
                lng: CameraConstants.initialLongitude
            ),
            zoomTo: CameraConstants.initialZoom
        )

        if animated {
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = CameraConstants.animationDuration
        }

        root.mapView.mapView.moveCamera(cameraUpdate)
    }

    /// 업소 정보 로드 실패 토스트
    func showStoreLoadFailedToast() {
        showToast(message: TextLiteral.Map.storeLoadFailed, type: .danger)
    }
}
