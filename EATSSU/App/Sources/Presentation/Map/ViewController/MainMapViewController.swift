//
//  MainMapViewController.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 6/24/25.
//

import UIKit

import NMapsMap
import Moya

import EATSSUDesign

final class MainMapViewController: BaseViewController, CLLocationManagerDelegate {

    // MARK: - Properties

    private let root = MainMapView()
    private let locationManager = CLLocationManager()
    private var currentDepartmentName: String?
    
    private var currentDepartmentId: Int?
    private var currentCollegeId: Int?

    private let partnershipProvider = MoyaProvider<PartnershipRouter>(
        session: Session(interceptor: AuthInterceptor.shared)
    )
    private let myProvider = MoyaProvider<MyRouter>(
        session: Session(interceptor: AuthInterceptor.shared)
    )

    private var markers: [NMFMarker] = []

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
        locationManager.requestWhenInUseAuthorization()

        // 네비게이션 바 스타일 설정
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

        setInitialCameraPosition(animated: false)

        // 초기 데이터 로드
        fetchDepartmentAndUpdateButton()
        fetchPartnerships()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 항상 '전체' 버튼이 선택된 상태로 초기화
        root.selectWhole(true)
        fetchDepartmentAndUpdateButton()
        fetchPartnerships()
    }

    // MARK: - Action

    /// "전체" 버튼 탭 시 호출
    @objc private func didTapWhole() {
        setInitialCameraPosition(animated: true)
        root.selectWhole(true)
        fetchPartnerships()
    }

    /// "내 제휴" 버튼 탭 시 호출
    @objc private func didTapMyOnly() {
        guard !(currentDepartmentName?.isEmpty ?? true) else {
            presentNoDepartmentSheet()
            return
        }
        if let collegeId = currentCollegeId, let majorId = currentDepartmentId {
            //  firebase - click_map_mine 이벤트 호출
            MapAnalyticsManager.shared.logClickMapMine(collegeId: collegeId, majorId: majorId)
        }
        setInitialCameraPosition(animated: true)
        root.selectWhole(false)
        fetchMyPartnerships()
    }

    /// 학과 미선택 시 바텀시트 표시
    private func presentNoDepartmentSheet() {
        let sheetVC = NoDepartmentSheetViewController()
        present(sheetVC, animated: true)
    }

    /// 외부에서 콘텐츠 새로고침 요청할 때 사용
    func reloadContent() {
        fetchDepartmentAndUpdateButton()
        if root.wholeButton.backgroundColor == EATSSUDesignAsset.Color.Main.primary.color {
            fetchPartnerships()
        } else {
            fetchMyPartnerships()
        }
    }
    
    /// 숭실대학교를 기준으로 카메라 위치를 설정
    private func setInitialCameraPosition(animated: Bool) {
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

    // MARK: - Location Delegate

    /// 위치 권한 변경 시 지도 카메라 이동
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            break
        default:
            break
        }
    }

    // MARK: - Marker Display

    /// 제휴 목록을 지도 마커로 표시
    private func displayMarkers(_ partnerships: [PartnershipDTO]) {
        markers.forEach { $0.mapView = nil }
        markers.removeAll()

        for partnership in partnerships {
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: partnership.latitude, lng: partnership.longitude)

            let markerImage = makeMarkerImage(type: partnership.restaurantType, title: partnership.storeName)
            marker.iconImage = NMFOverlayImage(image: markerImage)
            marker.width = CGFloat(UInt32(markerImage.size.width))
            marker.height = CGFloat(UInt32(markerImage.size.height))

            marker.touchHandler = { [weak self] _ in
                guard let self = self else { return true }

                let isMyPartnershipSelected = self.root.wholeButton.backgroundColor != EATSSUDesignAsset.Color.Main.primary.color

                if isMyPartnershipSelected {
                    if let partnerId = partnership.partnershipInfos.first?.id {
                        //  firebase - click_partner_restaurant 이벤트 호출
                        MapAnalyticsManager.shared.logClickPartnerRestaurant(
                            collegeId: self.currentCollegeId,
                            majorId: self.currentDepartmentId,
                            partnerId: partnerId
                        )
                    }
                }

                let sheetVC = PartnershipDetailSheetViewController(
                    storeName: partnership.storeName,
                    restaurantType: partnership.restaurantType,
                    partnershipInfos: partnership.partnershipInfos
                )

                if let sheet = sheetVC.sheetPresentationController {
                    if #available(iOS 16.0, *) {
                        sheetVC.loadViewIfNeeded()
                        let contentHeight = sheetVC.calculatePreferredHeight()
                        let customDetent = UISheetPresentationController.Detent.custom { _ in
                            return contentHeight
                        }
                        sheet.detents = [customDetent, .large()]
                    } else {
                        sheet.detents = [.medium(), .large()]
                    }
                    sheet.prefersGrabberVisible = true
                }

                self.present(sheetVC, animated: true)
                
                return true
            }
            marker.mapView = root.mapView.mapView
            markers.append(marker)
        }
    }
    
    /// 마커에 들어갈 커스텀 이미지 생성
    private func makeMarkerImage(type: String, title: String) -> UIImage {
        let icon: UIImage? = {
            switch type {
            case "RESTAURANT": return EATSSUDesignAsset.Images.restaurantPin.image
            case "CAFE":       return EATSSUDesignAsset.Images.cafePin.image
            case "PUB":        return EATSSUDesignAsset.Images.pubPin.image
            default:           return EATSSUDesignAsset.Images.restaurantPin.image
            }
        }()

        let markerView = MapMarkerView(icon: icon, title: title)
        markerView.layoutIfNeeded()
        markerView.frame = CGRect(origin: .zero, size: markerView.intrinsicContentSize)
        return markerView.toImage()
    }

    // MARK: - Network

    /// 전체 제휴 데이터 조회
    private func fetchPartnerships() {
        partnershipProvider.request(.getAllPartnerships) { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try response.map(BaseResponse<[PartnershipDTO]>.self)
                    guard let partnerships = decoded.result else { return }
                    self?.displayMarkers(partnerships)
                } catch {
                    print("전체 제휴 디코딩 실패: \(error.localizedDescription)")
                }
            case .failure(let error):
                print("전체 제휴 네트워크 오류: \(error.localizedDescription)")
            }
        }
    }

    /// 유저 학과 조회 및 버튼 타이틀 업데이트
    private func fetchDepartmentAndUpdateButton() {
        myProvider.request(.getDepartment) { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try response.map(BaseResponse<GetDepartmentResponse>.self)
                    let departmentName = decoded.result?.departmentName ?? ""
                    self?.currentDepartmentName = departmentName
                    self?.currentDepartmentId = decoded.result?.departmentId
                    self?.currentCollegeId = decoded.result?.collegeId
                    let buttonTitle = departmentName.isEmpty ? "내 제휴" : departmentName
                    self?.root.myOnlyButton.setTitle(buttonTitle, for: .normal)
                } catch {
                    print("학과 디코딩 실패: \(error)")
                    self?.currentDepartmentName = nil
                    self?.currentDepartmentId = nil
                    self?.currentCollegeId = nil
                    self?.root.myOnlyButton.setTitle("내 제휴", for: .normal)
                }
            case .failure(let error):
                print("학과 API 실패: \(error)")
                self?.currentDepartmentName = nil
                self?.currentDepartmentId = nil
                self?.currentCollegeId = nil
                self?.root.myOnlyButton.setTitle("내 제휴", for: .normal)
            }
        }
    }

    /// 내 제휴 데이터 조회
    private func fetchMyPartnerships() {
        myProvider.request(.getMyPartnerships) { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try response.map(BaseResponse<[PartnershipDTO]>.self)
                    guard let partnerships = decoded.result else { return }
                    self?.displayMarkers(partnerships)
                } catch {
                    print("내 제휴 디코딩 실패: \(error)")
                }
            case .failure(let error):
                print("내 제휴 네트워크 오류: \(error)")
            }
        }
    }
}
