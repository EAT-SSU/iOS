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

        // Remote Config에 따라 축제 탭 노출 여부 결정
        let festivalEnabled = FirebaseRemoteConfig.shared.isFestivalEnabled
        root.setFestivalVisible(festivalEnabled)

        fetchDepartmentAndUpdateButton { [weak self] in
            guard let self = self else { return }

            if festivalEnabled {
                self.currentMapMode = .festival
                self.root.select(.festival)
                self.refreshAllPartnerships()
            } else if let departmentName = self.currentDepartmentName, !departmentName.isEmpty {
                self.currentMapMode = .myOnly
                self.root.select(.myOnly)
                self.fetchMyPartnerships()
            } else {
                self.currentMapMode = .all
                self.root.select(.all)
                self.refreshAllPartnerships()
            }
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
        MapAnalyticsManager.shared.logClickMapFestival(
            collegeId: currentCollegeId,
            majorId: currentDepartmentId
        )
        applyCachedMarkers()
    }

    @objc private func didTapWhole() {
        guard currentMapMode != .all else { return }

        currentMapMode = .all
        setInitialCameraPosition(animated: true)
        root.select(.all)
        MapAnalyticsManager.shared.logClickMapAll(
            collegeId: currentCollegeId,
            majorId: currentDepartmentId
        )
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
                // 학과가 없어졌다면 축제 활성 여부에 따라 폴백
                if self.currentDepartmentName?.isEmpty ?? true {
                    if FirebaseRemoteConfig.shared.isFestivalEnabled {
                        self.didTapFestival()
                    } else {
                        self.didTapWhole()
                    }
                } else {
                    self.fetchMyPartnerships()
                }
            }
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
    
}
