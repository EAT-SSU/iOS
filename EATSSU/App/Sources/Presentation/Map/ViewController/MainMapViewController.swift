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
        /// 특정 업체를 보여줄 때의 줌. 이웃 마커와 클러스터로 뭉치지 않을 만큼 당긴다
        static let detailZoom: Double = 17
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
    /// 비로그인 진입 시 현위치로 이동하기 위해 권한/위치 응답을 기다리는 중인지
    var wantsInitialCurrentLocation = false

    var clusterer: NMCClusterer<MapMarkerKey>?

    /// 축제 제휴 캐시 (전체 제휴 응답에서 FESTIVAL 항목만 추린 것)
    var cachedFestivalPartnerships: [PartnershipDTO] = []
    /// 내 학과 제휴 캐시 (업종 칩 필터용). 탭바 재탭·학과 변경 시 비움
    var cachedMyPartnerships: [PartnershipDTO] = []
    /// 내 제휴 조회를 한 번이라도 시도했는지 (실패 포함). 찜 → 상세 진입이 무한정 대기하지 않도록 쓴다
    var hasAttemptedMyPartnershipsFetch = false
    /// 내 제휴를 성공적으로 받았는지 (빈 응답도 성공). 재요청 여부 판단용
    var hasLoadedMyPartnerships = false
    /// 축제 제휴를 성공적으로 받았는지 (빈 응답도 성공)
    var hasLoadedFestivalPartnerships = false
    private var isLoadingMyPartnershipsForDetail = false
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

    /// 자동 노출 예약을 무효화하기 위한 토큰 (연속 탭 시 이전 예약이 배너를 닫지 않도록)
    private var festivalBannerToken = 0
    /// 축제 안내 자동 노출은 앱 실행당 한 번만
    private static var hasAutoShownFestivalBanner = false

    /// 축제 제휴를 함께 보여주는 기간인지 (Remote Config)
    var isFestivalPartnershipEnabled: Bool {
        FirebaseRemoteConfig.shared.isFestivalPartnershipEnabled
    }

    /// 지도 탭 진입 시 축제 제휴가 함께 보이는 상태인지 (click_map default_type용)
    var isShowingFestival: Bool {
        currentTab == .partnership && isFestivalPartnershipEnabled
    }

    /// 클러스터 색상: 기존 제휴와 축제 제휴가 한 클러스터에 섞이므로 기본 색을 쓴다
    var clusterColor: UIColor { .primary }

    // MARK: - Init

    init(mode: Mode = .tabbed) {
        self.mode = mode
        self.currentTab = (mode == .standaloneGoodPrice) ? .goodPrice : .partnership
        super.init(nibName: nil, bundle: nil)
        // 서버 조회 전에도 로그인 시 저장된 학과로 판정할 수 있게 미리 채운다
        seedDepartmentFromRealmIfNeeded()
    }

    /// 학과 정보가 비어 있으면 Realm 저장값으로 채운다 (서버 조회 실패 시 폴백)
    func seedDepartmentFromRealmIfNeeded() {
        guard currentDepartmentName == nil,
              let userInfo = UserInfoManager.shared.getCurrentUserInfo(),
              let name = userInfo.departmentName, !name.isEmpty else { return }
        currentDepartmentName = name
        currentDepartmentId = userInfo.departmentId
        currentCollegeId = userInfo.collegeId
    }

    /// 찜 목록에서 넘어온 업체. 지도 탭이 화면에 나타난 뒤 시트로 띄우고 비운다
    private var pendingDetailStore: PartnershipDTO?

    /// 찜 목록에서 넘어온 상태. 네비게이션 바 뒤로가기가 찜 탭 복귀로 동작한다
    private var returnsToLikeTab = false

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Setup

    override func configureUI() {
        view.addSubview(root)
        root.setTopTabVisible(mode == .tabbed)
        root.setLikeButtonVisible(mode == .tabbed)
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
        root.likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        root.mapView.mapView.addCameraDelegate(delegate: self)

        configureNavigationBar()
        setEntryCameraPosition()
        setupLocationButtonObserver()
        setupMarkerTapHandler()
        setupFestivalHelp()
        applyTabUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        switch currentTab {
        case .partnership:
            refreshPartnershipTab()
        case .goodPrice:
            loadGoodPriceMarkers()
        }
        // Remote Config 수신이 늦을 수 있어 진입할 때마다 다시 판단한다
        updateFestivalHelpVisibility()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logScreenView(screenID: FirebaseScreenID.Map.map1)

        // 찜 목록에서 넘어온 업체가 있으면 화면이 붙은 뒤 시트를 띄운다
        presentPendingDetailIfNeeded()
        showFestivalBannerOnFirstEntryIfNeeded()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 다른 탭으로 옮겨가면 찜 복귀 상태와 아직 못 띄운 상세를 함께 버린다 (나중에 엉뚱하게 뜨지 않도록)
        pendingDetailStore = nil
        if returnsToLikeTab {
            returnsToLikeTab = false
            updateLikeReturnButton()
        }
    }

    // MARK: - Like

    /// 찜 목록에서 업체를 선택했을 때: 학교 제휴 탭으로 맞추고, 지도가 나타나면 해당 업체 시트를 띄운다
    func showDetailFromLikes(_ store: PartnershipDTO) {
        if currentTab != .partnership {
            switchTab(to: .partnership)
        }
        // 학과 확인이 끝난 뒤 판단한다 (Realm에 없어도 서버 조회로 학과가 확인될 수 있음)
        pendingDetailStore = store
        returnsToLikeTab = true
        updateLikeReturnButton()
        presentPendingDetailIfNeeded()
    }

    func presentPendingDetailIfNeeded() {
        guard let store = pendingDetailStore,
              viewIfLoaded?.window != nil,
              presentedViewController == nil else { return }
        guard hasDepartment else {
            // 학과가 없으면 학교 제휴 자체를 볼 수 없으므로 학과 안내가 대신 뜬다. 조회가 끝나기 전엔 보류
            if departmentLoadState == .loaded { pendingDetailStore = nil }
            return
        }
        // 내 제휴 응답 전이면 받아온 뒤 연다 (전체 단과대 원본 시트가 잠깐 노출되는 것 방지)
        if !hasAttemptedMyPartnershipsFetch, cachedMyPartnerships.isEmpty {
            loadMyPartnershipsForPendingDetail()
            return
        }
        pendingDetailStore = nil
        moveCamera(
            to: NMGLatLng(lat: store.latitude, lng: store.longitude),
            zoom: CameraConstants.detailZoom,
            animated: false
        )
        // 찜 원본 DTO는 모든 단과대 제휴를 담고 있어, 지도 마커와 동일하게 내 제휴 데이터로 표시한다
        // (내 제휴에 없으면 — 학과 변경 등 — 원본으로 폴백, 시트에서 내용 기준 중복 제거)
        let display = cachedMyPartnerships.first { $0.storeKey == store.storeKey } ?? store
        showPartnershipDetail(for: display, likeTarget: Self.likeTarget(for: store))
    }

    /// 찜 → 상세 진입용 내 제휴 확보. 마커 로드 세대에 영향을 주지 않도록 캐시만 채운다
    /// 실패해도 완료 표시 후 다시 호출해, 시트가 원본(중복 제거) 폴백으로라도 열리게 한다
    private func loadMyPartnershipsForPendingDetail() {
        guard !isLoadingMyPartnershipsForDetail else { return }
        isLoadingMyPartnershipsForDetail = true
        NetworkService.shared.request(
            MyRouter.getMyPartnerships,
            responseType: [PartnershipDTO].self,
            useAuth: true
        ) { [weak self] result in
            guard let self else { return }
            self.isLoadingMyPartnershipsForDetail = false
            if case .success(let partnerships) = result, self.cachedMyPartnerships.isEmpty {
                self.cachedMyPartnerships = partnerships
                self.hasLoadedMyPartnerships = true
            }
            self.hasAttemptedMyPartnershipsFetch = true
            self.presentPendingDetailIfNeeded()
        }
    }

    /// 찜 목록에서 넘어온 경우에만 뒤로가기(찜 탭 복귀) 버튼을 보여준다
    private func updateLikeReturnButton() {
        guard returnsToLikeTab else {
            navigationItem.leftBarButtonItem = nil
            return
        }
        let backItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(didTapReturnToLikes)
        )
        backItem.tintColor = .gray500
        navigationItem.leftBarButtonItem = backItem
    }

    @objc private func didTapReturnToLikes() {
        returnsToLikeTab = false
        updateLikeReturnButton()
        let container = tabBarController as? CustomTabBarContainerController
        if let presented = presentedViewController {
            presented.dismiss(animated: true) { container?.showLikedPartnerships(fromMap: false) }
        } else {
            container?.showLikedPartnerships(fromMap: false)
        }
    }

    @objc private func didTapLikeButton() {
        (tabBarController as? CustomTabBarContainerController)?.showLikedPartnerships(fromMap: true)
    }

    /// 학과 정보를 다시 받아온 뒤 학교 제휴 마커 로드
    private func refreshPartnershipTab() {
        applyTabUI()
        let generation = beginLoad()
        departmentLoadState = .loading
        fetchDepartment { [weak self] in
            guard let self, self.isCurrentLoad(generation) else { return }
            self.departmentLoadState = .loaded
            self.loadPartnershipMarkers()
            // 학과 확인을 기다리던 찜 상세가 있으면 이제 띄운다
            self.presentPendingDetailIfNeeded()
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
        // 찜은 학교 제휴 전용이라 착한 가격 탭에서는 플로팅 하트를 숨긴다
        root.setLikeButtonVisible(mode == .tabbed && currentTab == .partnership)
        updateFestivalHelpVisibility()

        switch currentTab {
        case .partnership:
            let filters = PartnershipFilter.allCases
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
        switch tab {
        case .partnership:
            // 학교 제휴는 숭실대 상권 기준. 착한가격에서 걸어둔 현위치 이동 대기도 취소한다
            wantsInitialCurrentLocation = false
            setInitialCameraPosition(animated: true)
        case .goodPrice:
            // 착한가격은 위치 권한이 있으면 항상 현위치 기준, 없으면 숭실대
            moveToCurrentLocationIfAvailable(animated: true)
        }

        switch tab {
        case .partnership:
            refreshPartnershipTab()
        case .goodPrice:
            root.setMapBlurred(false)
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
            logPartnershipFilterClick()
            loadPartnershipMarkers()

        case .goodPrice:
            let categories = GoodPriceCategory.allCases
            guard categories.indices.contains(index) else { return }
            goodPriceCategory = categories[index]
            MapAnalyticsManager.shared.logClickGoodPriceCategory(category: goodPriceCategory)
            loadGoodPriceMarkers()
        }
        // 필터 전환 시 카메라는 보고 있던 위치를 그대로 유지한다 (QA)
    }

    /// 학교 제휴는 곧 내 학과 제휴이고 학과 없이는 칩까지 도달할 수 없으므로 전체 제휴(click_map_all) 분기는 없다
    private func logPartnershipFilterClick() {
        guard let collegeId = currentCollegeId, let majorId = currentDepartmentId else { return }
        MapAnalyticsManager.shared.logClickMapMine(collegeId: collegeId, majorId: majorId)
    }

    // MARK: - Partnership Tab

    /// 학교 제휴 탭 마커 로드. 학과 미입력이면 지도를 흐리게 하고 학과 입력 시트를 띄운다 (축제 포함 모든 필터)
    func loadPartnershipMarkers() {
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
                root.setMapBlurred(true)
                updateFestivalHelpVisibility()
                presentNoDepartmentSheetIfNeeded()
                return
            }
        }
        root.setMapBlurred(false)
        updateFestivalHelpVisibility()
        fetchPartnerships()
    }

    var hasDepartment: Bool {
        !(currentDepartmentName?.isEmpty ?? true)
    }

    private func presentNoDepartmentSheetIfNeeded() {
        // 비동기 응답 시점에 다른 탭에 있으면 띄우지 않는다 (다음 진입 시 viewWillAppear가 다시 판단)
        guard mode == .tabbed, currentTab == .partnership,
              presentedViewController == nil,
              viewIfLoaded?.window != nil else { return }
        present(NoDepartmentSheetViewController(), animated: true)
    }

    // MARK: - Festival Help

    private enum FestivalBanner {
        static let autoHideDelay: TimeInterval = 2.5
        static let fadeDuration: TimeInterval = 0.2
    }

    /// 축제 도움말은 학교 제휴 탭 + 축제 기간 + 학과 보유 시에만 노출 (학과 없으면 지도가 블러 처리된다)
    func updateFestivalHelpVisibility() {
        root.setFestivalHelpVisible(
            currentTab == .partnership && isFestivalPartnershipEnabled && hasDepartment
        )
    }

    private func setupFestivalHelp() {
        root.festivalHelpButton.addTarget(self, action: #selector(didTapFestivalHelp), for: .touchUpInside)
        root.festivalBannerView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapFestivalBanner))
        )
    }

    @objc private func didTapFestivalHelp() {
        if root.festivalBannerView.isHidden {
            showFestivalBanner()
        } else {
            hideFestivalBanner()
        }
    }

    @objc private func didTapFestivalBanner() {
        hideFestivalBanner()
    }

    /// 안내 말풍선을 띄우고 일정 시간 뒤 자동으로 닫는다
    private func showFestivalBanner() {
        guard isFestivalPartnershipEnabled, currentTab == .partnership else { return }

        festivalBannerToken += 1
        let token = festivalBannerToken
        root.festivalBannerView.alpha = 0
        root.festivalBannerView.isHidden = false
        UIView.animate(withDuration: FestivalBanner.fadeDuration) {
            self.root.festivalBannerView.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + FestivalBanner.autoHideDelay) { [weak self] in
            // 그 사이에 다시 열거나 닫았으면 이 예약은 버린다
            guard let self, self.festivalBannerToken == token else { return }
            self.hideFestivalBanner()
        }
    }

    func hideFestivalBanner() {
        guard !root.festivalBannerView.isHidden else { return }
        festivalBannerToken += 1
        UIView.animate(
            withDuration: FestivalBanner.fadeDuration,
            animations: { self.root.festivalBannerView.alpha = 0 },
            completion: { _ in self.root.festivalBannerView.isHidden = true }
        )
    }

    /// 축제 기간 중 지도 첫 진입 시 한 번 자동으로 안내한다 (앱 실행당 1회)
    private func showFestivalBannerOnFirstEntryIfNeeded() {
        guard isFestivalPartnershipEnabled, currentTab == .partnership, hasDepartment,
              !Self.hasAutoShownFestivalBanner else { return }
        Self.hasAutoShownFestivalBanner = true
        showFestivalBanner()
    }

    // MARK: - Helper Methods

    /// 탭바에서 지도 탭을 다시 눌렀을 때 현재 탭 데이터 갱신
    func reloadContent() {
        switch currentTab {
        case .partnership:
            cachedFestivalPartnerships = []
            hasLoadedFestivalPartnerships = false
            cachedMyPartnerships = []
            hasLoadedMyPartnerships = false
            hasAttemptedMyPartnershipsFetch = false
            refreshPartnershipTab()
        case .goodPrice:
            cachedGoodPriceStores = []
            loadGoodPriceMarkers()
        }
    }

    /// 진입 시 카메라 위치. 로그인(탭 지도)은 숭실대 상권, 비로그인(단독 착한가격)은 현위치(권한 없으면 숭실대)
    private func setEntryCameraPosition() {
        setInitialCameraPosition(animated: false)
        guard mode == .standaloneGoodPrice else { return }
        moveToCurrentLocationIfAvailable()
    }

    func setInitialCameraPosition(animated: Bool) {
        moveCamera(
            to: NMGLatLng(lat: CameraConstants.initialLatitude, lng: CameraConstants.initialLongitude),
            animated: animated
        )
    }

    /// 지정 좌표로 카메라 이동
    func moveCamera(to position: NMGLatLng, zoom: Double = CameraConstants.initialZoom, animated: Bool) {
        let cameraUpdate = NMFCameraUpdate(scrollTo: position, zoomTo: zoom)

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
