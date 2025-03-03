//
//  MapViewController.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 1/28/25.
//

import UIKit

import EATSSUDesign
import EATSSUKit

import FloatingPanel
import NMapsMap
import RxSwift
import SnapKit

final class MapViewController: BaseViewController {
    // MARK: - Properties

    private let partnershipService = PartnershipService()
    private let userDepartmentService = UserDepartmentService()
    private let disposeBag = DisposeBag()
    private var mapView: NMFMapView!
    private var mapSegmentedControl: UISegmentedControl!
    private var floatingPanelController: FloatingPanelController?
    private var selectedMarkerData: MarkerData?
    private let soongsilUniversityLocation = NMGLatLng(lat: 37.496389, lng: 126.957222)
    private var esMarkers: [ESMarker] = []

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureMapView()
        configureSegmentedControl()
    }

    override func viewWillAppear(_: Bool) {
        fetchAllPartnershipsAndDisplay()
        resetSegmentedControlToDefault()
    }
}

// MARK: - UI Configuration

private extension MapViewController {
    /// 네비게이션 바 스타일을 설정합니다.
    func configureNavigationBar() {
        navigationItem.title = ESTextLiteral.Map.mapNavTitle
        navigationController?.isNavigationBarHidden = false

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [
            .font: EATSSUDesignFontFamily.Pretendard.bold.font(size: 16),
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    /// 네이버 지도 뷰를 초기화하고 화면에 추가합니다.
    func configureMapView() {
        mapView = NMFMapView(frame: view.frame)
        view.addSubview(mapView)
        mapView.touchDelegate = self
        moveCameraToLocation(soongsilUniversityLocation, zoomLevel: 15.0)
    }

    /**
     카메라를 특정 위치로 이동합니다.
     - Parameters:
       - location: 이동할 위치의 위도 및 경도 (`NMGLatLng`)
       - zoomLevel: 줌 레벨 (`Double`)
     */
    func moveCameraToLocation(_ location: NMGLatLng, zoomLevel: Double) {
        let cameraUpdate = NMFCameraUpdate(position: NMFCameraPosition(location, zoom: zoomLevel))
        mapView.moveCamera(cameraUpdate)
    }

    /// 지도 상단에 `UISegmentedControl`을 추가하고 초기 설정을 적용합니다.
    func configureSegmentedControl() {
        let items = ["전체", "내 제휴"]
        mapSegmentedControl = UISegmentedControl(items: items)
        mapSegmentedControl.selectedSegmentIndex = 0
        mapSegmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)

        mapSegmentedControl.backgroundColor = .white
        mapSegmentedControl.selectedSegmentTintColor = EATSSUDesignAsset.Color.Main.primary.color
        mapSegmentedControl.layer.cornerRadius = 50
        mapSegmentedControl.layer.masksToBounds = true

        let font = EATSSUDesignFontFamily.Pretendard.semiBold.font(size: 14)
        mapSegmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.white, .font: font],
            for: .selected
        )
        mapSegmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.black, .font: font],
            for: .normal
        )

        view.addSubview(mapSegmentedControl)
        mapSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(145)
        }

        view.bringSubviewToFront(mapSegmentedControl)
    }

    /// 세그먼트 컨트롤을 기본 상태(전체)로 초기화합니다.
    func resetSegmentedControlToDefault() {
        mapSegmentedControl.selectedSegmentIndex = 0
    }

    /**
     Segmented Control 변경 이벤트 핸들러입니다.
     - Parameter sender: 값을 변경한 `UISegmentedControl` 인스턴스
     */
    @objc func segmentedControlChanged(_ sender: UISegmentedControl) {
        removeAllMarkersFromMap()

        #if DEBUG
            print("Selected segment index: \(sender.selectedSegmentIndex)")
        #endif

        switch sender.selectedSegmentIndex {
        case 0:
            #if DEBUG
                print("전체 제휴 업체를 가져옵니다.")
            #endif
            fetchAllPartnershipsAndDisplay()
        case 1:
            #if DEBUG
                print("사용자의 제휴 업체를 가져옵니다.")
            #endif
            fetchUserPartnershipsAndDisplay()
        default:
            AlertControllerHelper.showConfirmAlert(
                title: "에러",
                message: "문제가 발생했습니다",
                in: self
            )
        }
    }
}

// MARK: - Marker Management

private extension MapViewController {
    /**
     특정 위치에 마커를 추가합니다.
     - Parameters:
       - location: 마커를 추가할 `NMGLatLng` 위치
       - leftText: 마커 왼쪽에 표시할 텍스트
       - rightText: 마커 오른쪽에 표시할 텍스트
       - markerData: 해당 마커에 대응하는 `MarkerData` (상세보기용 정보)
     */
    func createAndAddMarker(
        at location: NMGLatLng,
        leftText: String,
        rightText: String,
        markerData: MarkerData
    ) {
        let marker = ESMarker(
            position: location,
            leftText: leftText,
            rightText: rightText,
            touchHandler: { (_: NMFOverlay) -> Bool in
                #if DEBUG
                    print("마커가 탭되었습니다!")
                #endif
                self.showMarkerDetailPanel(with: markerData)
                return true
            },
            markerData: markerData
        )
        marker.marker.mapView = mapView
        esMarkers.append(marker)
    }

    /// 지도에 추가된 모든 마커를 제거합니다.
    func removeAllMarkersFromMap() {
        for marker in esMarkers {
            marker.marker.mapView = nil
        }
        esMarkers.removeAll()
    }

    /**
     파트너십 응답 데이터를 기반으로 지도에 마커들을 생성하고 표시합니다.
     - Parameter partnerships: 서버로부터 받은 파트너십 응답 데이터 배열
     */
    func displayPartnershipsOnMap(from partnerships: [PartnershipResponse]) {
        for partnership in partnerships {
            let location = NMGLatLng(
                lat: partnership.latitude,
                lng: partnership.longitude
            )
            let markerData = MarkerData(
                id: partnership.id,
                title: partnership.storeName,
                description: partnership.description
            )

            createAndAddMarker(
                at: location,
                leftText: partnership.storeName,
                rightText: partnership.partnershipType,
                markerData: markerData
            )
        }
    }
}

// MARK: - FloatingPanel Management

private extension MapViewController {
    /**
     마커 상세 정보를 `FloatingPanel`로 표시합니다.
     - Parameter markerData: 마커 클릭 시 표시할 데이터(`MarkerData`)
     */
    func showMarkerDetailPanel(with markerData: MarkerData) {
        if let currentData = selectedMarkerData, currentData == markerData,
           floatingPanelController?.parent != nil
        {
            return
        }

        selectedMarkerData = markerData
        let detailVC = MarkerDetailViewController(markerData: markerData)

        if floatingPanelController == nil {
            initializeFloatingPanelController()
        }

        floatingPanelController?.set(contentViewController: detailVC)

        if floatingPanelController?.parent == nil {
            floatingPanelController?.addPanel(toParent: self)
        }
    }

    /// FloatingPanelController를 초기화하고 appearance를 설정합니다.
    func initializeFloatingPanelController() {
        floatingPanelController = FloatingPanelController()
        floatingPanelController?.delegate = self
        configureFloatingPanelAppearance()
    }

    /// FloatingPanel의 appearance를 설정합니다.
    func configureFloatingPanelAppearance() {
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 15
        floatingPanelController?.surfaceView.appearance = appearance
    }

    /// FloatingPanel을 제거하고 선택된 마커 데이터를 초기화합니다.
    func removeFloatingPanel() {
        floatingPanelController?.removePanelFromParent(animated: true)
        floatingPanelController = nil
        selectedMarkerData = nil
    }
}

// MARK: - Network Operations

private extension MapViewController {
    /// 전체 제휴 목록을 네트워크로부터 가져와 표시합니다.
    func fetchAllPartnershipsAndDisplay() {
        partnershipService.fetchAllPartnerships()
            .subscribe(
                onSuccess: { [weak self] (baseResponse: BaseResponse<[PartnershipResponse]>) in
                    guard let self else { return }

                    #if DEBUG
                        print("제휴 목록 가져오기 성공: \(baseResponse)")
                    #endif

                    guard baseResponse.isSuccess else {
                        #if DEBUG
                            print("제휴 목록 가져오기 실패: \(baseResponse.message)")
                        #endif
                        return
                    }

                    displayPartnershipsOnMap(from: baseResponse.result)
                },
                onFailure: { [weak self] error in
                    self?.showPartnershipErrorAlert(error)
                }
            )
            .disposed(by: disposeBag)
    }

    /// 사용자의 학과/단과대 관련 제휴 목록을 네트워크로부터 가져와 표시합니다.
    func fetchUserPartnershipsAndDisplay() {
        userDepartmentService.getUserPartnership()
            .subscribe(
                onSuccess: { [weak self] (baseResponse: BaseResponse<[PartnershipResponse]>) in
                    guard let self else { return }

                    #if DEBUG
                        print("사용자 제휴 목록 가져오기 성공: \(baseResponse)")
                    #endif

                    guard baseResponse.isSuccess else {
                        #if DEBUG
                            print("사용자 제휴 목록 가져오기 실패: \(baseResponse.message)")
                        #endif
                        return
                    }

                    displayPartnershipsOnMap(from: baseResponse.result)
                },
                onFailure: { [weak self] error in
                    self?.showPartnershipErrorAlert(error)
                }
            )
            .disposed(by: disposeBag)
    }

    /**
     파트너십 데이터 요청 실패 시 에러 알림을 표시합니다.
     - Parameter error: 발생한 에러 객체
     */
    func showPartnershipErrorAlert(_ error: Error) {
        #if DEBUG
            print("제휴 목록 가져오기 실패: \(error.localizedDescription)")
        #endif
        AlertControllerHelper.showConfirmAlert(
            title: "문제가 발생했습니다",
            message: "다시 시도하세요",
            confirmTitle: "확인",
            in: self
        )
    }
}

// MARK: - NMFMapViewTouchDelegate

extension MapViewController: NMFMapViewTouchDelegate {
    /**
     사용자가 지도에서 단일 탭했을 때 호출됩니다.
     마커가 아닌 다른 부분을 탭하면 FloatingPanel을 제거합니다.
     - Parameters:
       - latlng: 탭한 위치의 `NMGLatLng`
       - point: 탭한 화면 좌표(`CGPoint`)
     */
    func mapView(_: NMFMapView, didTapMap latlng: NMGLatLng, point _: CGPoint) {
        if let fpc = floatingPanelController, fpc.parent != nil {
            removeFloatingPanel()
        }
        #if DEBUG
            print("탭: \(latlng.lat), \(latlng.lng)")
        #endif
    }

    /**
     사용자가 지도에서 길게 누를 때 호출됩니다.
     마커가 아닌 다른 부분을 길게 누르면 FloatingPanel을 제거합니다.
     - Parameters:
       - latlng: 길게 누른 위치의 `NMGLatLng`
       - point: 터치된 화면 좌표(`CGPoint`)
     */
    func mapView(_: NMFMapView, didLongTapMap latlng: NMGLatLng, point _: CGPoint) {
        if let fpc = floatingPanelController, fpc.parent != nil {
            removeFloatingPanel()
        }
        #if DEBUG
            print("롱 탭: \(latlng.lat), \(latlng.lng)")
        #endif
    }
}

// MARK: - FloatingPanelControllerDelegate

extension MapViewController: FloatingPanelControllerDelegate {
    /// FloatingPanel이 제거되었을 때 호출됩니다.
    func floatingPanelDidRemove(_: FloatingPanelController) {
        removeFloatingPanel()
    }
}
