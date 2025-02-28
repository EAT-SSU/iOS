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

/**
 # MapViewController
 네이버 지도를 표시하고, 제휴 업체(Partnership) 정보를 받아와 지도에 마커를 추가하는 역할을 담당하는 뷰 컨트롤러입니다.

 ## 기능
 - 숭실대학교를 기준으로 지도를 초기화합니다.
 - 전체 제휴 업체 목록을 네트워크로부터 가져와 마커를 배치합니다.
 - `UISegmentedControl`을 이용해 '내 제휴' / '전체' 등 원하는 정보만 지도 위에 표시할 수 있습니다.
 - 마커를 탭하면 `FloatingPanel`을 이용해 선택한 마커의 상세 정보를 표시합니다.
 - 지도 영역 외부를 탭하면 패널을 닫고 선택 상태를 해제합니다.

 ## 사용 예시
 1. `MapViewController`를 생성합니다.
 2. 내비게이션 컨트롤러에 `MapViewController`를 포함시켜 화면에 표시합니다.
 3. 화면에 표시된 지도를 통해 제휴 업체 정보를 확인하고, 마커를 탭하면 상세 정보를 확인할 수 있습니다.

 - Author: **JIWOONG CHOI**
 - Date: 2025.01.28
 - SeeAlso: `MarkerDetailViewController`, `FloatingPanelController`
 */
final class MapViewController: BaseViewController {
    // MARK: - Properties

    /// `PartnershipService` 인스턴스. 제휴 업체 정보를 가져오는 데 사용됩니다.
    private let partnershipService = PartnershipService()

    /// `UserDepartmentService` 인스턴스. 사용자의 학부와 관련된 정보를 서버에 요청하는 객체입니다.
    private let userDepartmentService = UserDepartmentService()

    /// Rx에서 사용되는 DisposeBag입니다.
    private let disposeBag = DisposeBag()

    /// 네이버 지도 뷰입니다.
    private var mapView: NMFMapView!

    /// 지도 상단에 표시되는 UISegmentedControl
    private var mapSegmentedControl: UISegmentedControl!

    /// FloatingPanelController 인스턴스 (패널이 띄워져 있을 때 참조)
    private var floatingPanelController: FloatingPanelController?

    /// 현재 선택된 마커 데이터를 저장합니다.
    private var selectedMarkerData: MarkerData?

    /// 숭실대학교 위치 (위도, 경도). 카메라를 이동할 기본 위치로 사용됩니다.
    private let soongsilUniversityLocation = NMGLatLng(lat: 37.496389, lng: 126.957222)

    /// 지도 위에 추가된 `ESMarker` 객체들을 저장합니다.
    private var esMarkers: [ESMarker] = []

    // MARK: - Life Cycle

    /**
     화면이 메모리에 로드되었을 때 호출됩니다.
     지도와 UI를 설정하고, 제휴 정보를 불러와 표시합니다.
     */
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
    /**
     네비게이션 바 스타일을 설정합니다.

     - Note: 배경색, 타이틀 폰트, 스크롤 시의 Appearance 등을 지정합니다.
     */
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

    // MARK: - 지도 설정

    /**
     네이버 지도 뷰를 초기화하고 화면에 추가합니다.

     - Note: 지도에서 터치 이벤트를 수신하기 위해 `touchDelegate`를 `self`로 설정합니다.
     - SeeAlso: `moveCamera(to:zoomLevel:)`
     */
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

    // MARK: - UISegmentedControl 설정

    /**
     지도 상단에 `UISegmentedControl`을 추가하고 초기 설정을 적용합니다.

     - Note: Segmented Control 클릭 시 `segmentedControlChanged(_:)`를 통해 새로운 데이터를 불러오거나, 기존 마커를 지우고 다시 표시합니다.
     */
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

    /**
     세그먼트 컨트롤을 기본 상태(전체)로 초기화합니다.
     
     - Note: viewWillAppear에서 호출되어 화면이 나타날 때마다 세그먼트 컨트롤을 초기 상태로 되돌립니다.
     */
    func resetSegmentedControlToDefault() {
        mapSegmentedControl.selectedSegmentIndex = 0
    }

    /**
     Segmented Control 변경 이벤트 핸들러입니다.

     - Parameter sender: 값을 변경한 `UISegmentedControl` 인스턴스

     분기:
     1. 0(기본: "내 제휴") 선택 시 전체 제휴 업체 데이터를 불러옵니다.
     2. 1("전체") 선택 시 사용자의 제휴 업체 데이터(미구현)를 불러옵니다.
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
     - Note: 마커를 탭하면 `presentMarkerDetailFloatingPanel(with:)`가 호출되어 상세 패널이 표시됩니다.
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

    /**
     지도에 추가된 모든 마커를 제거합니다.

     - Note: `esMarkers` 배열에 저장된 `ESMarker`를 순회하며, 지도에서 제거(MapView 연결 해제)한 뒤 배열을 비웁니다.
     */
    func removeAllMarkersFromMap() {
        for marker in esMarkers {
            marker.marker.mapView = nil
        }
        esMarkers.removeAll()
    }

    /**
     파트너십 응답 데이터를 기반으로 지도에 마커들을 생성하고 표시합니다.
     
     - Parameter partnerships: 서버로부터 받은 파트너십 응답 데이터 배열
     - Note: 각 파트너십 데이터에 대해 위치 정보와 마커 데이터를 생성하여 지도에 표시합니다.
     */
    func displayPartnershipsOnMap(from partnerships: [PartnershipResponse]) {
        for partnership in partnerships {
            let location = NMGLatLng(
                lat: partnership.latitude,
                lng: partnership.longitude
            )
            let markerData = MarkerData(
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
     - Note:
        1. 이미 동일한 마커가 선택되어 있고, 패널이 표시 중이면 그대로 유지합니다.
        2. 새로운 마커를 탭하면, `MarkerDetailViewController`를 생성해 패널 내용으로 설정하고 부모에 추가합니다.
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
            floatingPanelController = FloatingPanelController()
            floatingPanelController?.delegate = self

            let appearance = SurfaceAppearance()
            appearance.cornerRadius = 15
            floatingPanelController?.surfaceView.appearance = appearance
        }

        floatingPanelController?.set(contentViewController: detailVC)

        if floatingPanelController?.parent == nil {
            floatingPanelController?.addPanel(toParent: self)
        }
    }
}

// MARK: - Network Operations
private extension MapViewController {
    /**
     전체 제휴 목록을 네트워크로부터 가져오는 메서드입니다.

     - Note:
       1. 성공 시 `baseResponse.result`에 포함된 제휴 정보를 순회하며, 지도 위에 마커를 배치합니다.
       2. 실패 시 디버그 로그를 남기고, 필요 시 사용자에게 알림을 표시하도록 TODO를 남겼습니다.
     */
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

    /**
     사용자의 학과/단과대 관련 제휴 목록을 네트워크로부터 가져와 표시하는 메서드입니다.
     
     - Note:
       1. UserDepartmentService를 통해 사용자의 학과/단과대 관련 제휴 정보를 요청합니다.
       2. 성공 시 받아온 제휴 정보를 지도에 마커로 표시합니다.
       3. 실패 시 사용자에게 에러 알림을 표시합니다.
     */
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
     파트너십 데이터 요청 실패 시 에러 알림을 표시하는 함수입니다.
     
     - Parameter error: 발생한 에러 객체
     - Note: 디버그 모드에서는 에러 상세 정보를 로그로 출력하고, 사용자에게는 간단한 에러 메시지를 알림으로 표시합니다.
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
            fpc.removePanelFromParent(animated: true)
            floatingPanelController = nil
            selectedMarkerData = nil
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
            fpc.removePanelFromParent(animated: true)
            floatingPanelController = nil
            selectedMarkerData = nil
        }
        #if DEBUG
            print("롱 탭: \(latlng.lat), \(latlng.lng)")
        #endif
    }
}

// MARK: - FloatingPanelControllerDelegate
extension MapViewController: FloatingPanelControllerDelegate {
    /**
     FloatingPanel이 제거되었을 때 호출됩니다.
     패널과 선택된 마커 데이터를 초기화합니다.

     - Parameter fpc: 제거된 `FloatingPanelController`
     */
    func floatingPanelDidRemove(_: FloatingPanelController) {
        floatingPanelController = nil
        selectedMarkerData = nil
    }
}
