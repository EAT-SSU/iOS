//
//  MainMapViewController.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 6/24/25.
//

import UIKit

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

    var markers: [NMFMarker] = []
    
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
        loadDepartmentFromRealm()
        setupLocationButtonObserver()
        
        fetchDepartmentAndUpdateButton()
        fetchPartnerships()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logScreenView(screenID: FirebaseScreenID.Map.map1)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadDepartmentFromRealm()
        
        if let departmentName = currentDepartmentName, !departmentName.isEmpty {
            currentMapMode = .myOnly
            root.selectWhole(false)
            fetchMyPartnerships()
        } else {
            currentMapMode = .all
            root.selectWhole(true)
            fetchPartnerships()
        }
        
        fetchDepartmentAndUpdateButton()
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
        fetchDepartmentAndUpdateButton()
        switch currentMapMode {
        case .all:
            fetchPartnerships()
        case .myOnly:
            fetchMyPartnerships()
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
            root.myOnlyButton.setTitle("내 제휴", for: .normal)
            return
        }
        
        let departmentName = userInfo.departmentName ?? ""
        currentDepartmentName = departmentName
        currentDepartmentId = userInfo.departmentId
        currentCollegeId = userInfo.collegeId
        
        let buttonTitle = departmentName.isEmpty ? "내 제휴" : departmentName
        root.myOnlyButton.setTitle(buttonTitle, for: .normal)
    }
}
