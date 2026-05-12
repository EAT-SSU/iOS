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

    // MARK: - Properties

    let root = MainMapView()
    let locationManager = CLLocationManager()
    var currentDepartmentName: String?
    var currentDepartmentId: Int?
    var currentCollegeId: Int?
    var hasRequestedLocationPermission = false

    var clusterer: NMCClusterer<PartnershipMarkerKey>?

    /// 가장 최근에 받아온 전체 제휴 목록 (모드 전환 시 필터링용 캐시)
    var cachedAllPartnerships: [PartnershipDTO] = []

    // MARK: - Map Mode Management

    var currentMapMode: MapMode = .festival

    // MARK: - View Setup
    
    override func configureUI() {
        view.addSubview(root)
    }

    override func setLayout() {
        root.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    override func setButtonEvent() {
        root.festivalButton.addTarget(self, action: #selector(didTapFestival), for: .touchUpInside)
        root.wholeButton.addTarget(self, action: #selector(didTapWhole), for: .touchUpInside)
        root.myOnlyButton.addTarget(self, action: #selector(didTapMyOnly), for: .touchUpInside)
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self

        configureNavigationBar()
        setInitialCameraPosition(animated: false)
        setupLocationButtonObserver()
        setupMarkerTapHandler()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logScreenView(screenID: FirebaseScreenID.Map.map1)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 기본 진입은 축제 탭. 학과 정보는 내 제휴 버튼 라벨 갱신용으로만 사용
        fetchDepartmentAndUpdateButton { [weak self] in
            guard let self = self else { return }

            self.currentMapMode = .festival
            self.root.select(.festival)
            self.refreshAllPartnerships()
        }
    }

    // MARK: - Configuration
    
    private func configureNavigationBar() {
        title = TextLiteral.Map.map
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = .white
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: EATSSUDesignFontFamily.Pretendard.bold.font(size: 16)
        ]
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController?.navigationBar.compactAppearance = navBarAppearance
    }

    // MARK: - Action Methods

    @objc private func didTapFestival() {
        guard currentMapMode != .festival else { return }

        currentMapMode = .festival
        setInitialCameraPosition(animated: true)
        root.select(.festival)
        applyCachedMarkers()
    }

    @objc private func didTapWhole() {
        guard currentMapMode != .all else { return }

        currentMapMode = .all
        setInitialCameraPosition(animated: true)
        root.select(.all)
        applyCachedMarkers()
    }

    @objc private func didTapMyOnly() {
        guard !(currentDepartmentName?.isEmpty ?? true) else {
            presentNoDepartmentSheet()
            return
        }

        // 이미 학과별 모드면 return
        guard currentMapMode != .myOnly else { return }

        currentMapMode = .myOnly

        if let collegeId = currentCollegeId, let majorId = currentDepartmentId {
            MapAnalyticsManager.shared.logClickMapMine(collegeId: collegeId, majorId: majorId)
        }
        setInitialCameraPosition(animated: true)
        root.select(.myOnly)
        fetchMyPartnerships()
    }

    private func presentNoDepartmentSheet() {
        let sheetVC = NoDepartmentSheetViewController()
        present(sheetVC, animated: true)
    }

    // MARK: - Helper Methods
    
    func reloadContent() {
        // 학과 정보를 다시 불러온 후, 현재 모드에 맞게 데이터 갱신
        fetchDepartmentAndUpdateButton { [weak self] in
            guard let self = self else { return }
            switch self.currentMapMode {
            case .festival, .all:
                self.refreshAllPartnerships()
            case .myOnly:
                // 학과가 없어졌다면 축제로 전환
                if self.currentDepartmentName?.isEmpty ?? true {
                    self.didTapFestival()
                } else {
                    self.fetchMyPartnerships()
                }
            }
        }
    }
    
    func setInitialCameraPosition(animated: Bool) {
        let ssuLatitude = 37.49517278813046
        let ssuLongitude = 126.95661313346206
        
        let cameraUpdate = NMFCameraUpdate(
            scrollTo: NMGLatLng(lat: ssuLatitude, lng: ssuLongitude),
            zoomTo: 17.5
        )
        
        if animated {
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.3
        }
        
        root.mapView.mapView.moveCamera(cameraUpdate)
    }
    
}
