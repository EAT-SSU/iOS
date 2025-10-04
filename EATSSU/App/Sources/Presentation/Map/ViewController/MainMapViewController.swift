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
import FirebaseAnalytics

import EATSSUDesign

final class MainMapViewController: BaseViewController {

    // MARK: - Properties

    let root = MainMapView()
    let locationManager = CLLocationManager()
    var currentDepartmentName: String?
    var currentDepartmentId: Int?
    var currentCollegeId: Int?
    var hasRequestedLocationPermission = false

    let partnershipProvider = MoyaProvider<PartnershipRouter>(
        session: Session(interceptor: AuthInterceptor.shared)
    )
    let myProvider = MoyaProvider<MyRouter>(
        session: Session(interceptor: AuthInterceptor.shared)
    )

    var clusterer: NMCClusterer<PartnershipMarkerKey>?
    
    // MARK: - Map Mode Management
    
    enum MapMode {
        case all
        case myOnly
    }
    
    var currentMapMode: MapMode = .all

    // MARK: - View Setup
    
    override func configureUI() {
        view.addSubview(root)
    }

    override func setLayout() {
        root.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    override func setButtonEvent() {
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
        
        fetchDepartmentAndUpdateButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logScreenView(screenID: FirebaseScreenID.Map.map1)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 학과 정보 다시 로드
        loadDepartmentFromRealm()
        
        // 학과가 있으면 학과별 제휴로 시작, 없으면 전체로 시작
        if let departmentName = currentDepartmentName, !departmentName.isEmpty {
            currentMapMode = .myOnly
            root.selectWhole(false)
            fetchMyPartnerships()
        } else {
            currentMapMode = .all
            root.selectWhole(true)
            fetchPartnerships()
        }
        
        // 버튼 텍스트 업데이트
        updateMyOnlyButtonTitle()
    }

    // MARK: - Configuration
    
    private func configureNavigationBar() {
        title = "제휴 지도"
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

    @objc private func didTapWhole() {
        guard currentMapMode != .all else { return }
        
        currentMapMode = .all
        setInitialCameraPosition(animated: true)
        root.selectWhole(true)
        fetchPartnerships()
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
        root.selectWhole(false)
        fetchMyPartnerships()
    }

    private func presentNoDepartmentSheet() {
        let sheetVC = NoDepartmentSheetViewController()
        present(sheetVC, animated: true)
    }

    // MARK: - Helper Methods
    
    func reloadContent() {
        // 학과 정보를 다시 불러온 후, 현재 모드에 맞게 API 호출
        fetchDepartmentAndUpdateButton { [weak self] in
            guard let self = self else { return }
            switch self.currentMapMode {
            case .all:
                self.fetchPartnerships()
            case .myOnly:
                // 학과가 없어졌다면 전체로 전환
                if self.currentDepartmentName?.isEmpty ?? true {
                    self.didTapWhole()
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
    
    func loadDepartmentFromRealm() {
        guard let userInfo = UserInfoManager.shared.getCurrentUserInfo() else {
            currentDepartmentName = nil
            currentDepartmentId = nil
            currentCollegeId = nil
            updateMyOnlyButtonTitle()
            return
        }
        
        let departmentName = userInfo.departmentName ?? ""
        currentDepartmentName = departmentName
        currentDepartmentId = userInfo.departmentId
        currentCollegeId = userInfo.collegeId
        
        updateMyOnlyButtonTitle()
    }
    
    private func updateMyOnlyButtonTitle() {
        let buttonTitle = (currentDepartmentName?.isEmpty ?? true) ? "내 제휴" : currentDepartmentName!
        root.myOnlyButton.setTitle(buttonTitle, for: .normal)
    }
}
