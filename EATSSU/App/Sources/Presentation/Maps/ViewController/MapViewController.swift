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
import SnapKit

/// `MapViewController`는 네이버 지도를 표시하고, 마커를 추가하는 역할을 합니다.
final class MapViewController: BaseViewController {
    /// 네이버 지도 뷰
    private var mapView: NMFMapView!

    /// 지도 위에 추가할 UISegmentedControl
    private var mapSegmentedControl: UISegmentedControl!

    /// FloatingPanelController 인스턴스 (패널이 띄워져 있을 때 참조)
    private var floatingPanelController: FloatingPanelController?

    /// 숭실대학교 위치 (위도, 경도)
    private let soongsilUniversityLocation = NMGLatLng(lat: 37.496389, lng: 126.957222)

    /// 추가된 ESMarker들을 저장하는 배열
    private var esMarkers: [ESMarker] = []

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureMapView()
        setupSegmentedControl()
        addSoongsilMarker()
    }

    // MARK: - UI 설정

    /// UI를 초기화하고 네비게이션 바를 설정합니다.
    private func setupUI() {
        setNavigationBar()
    }

    /// 네비게이션 바 스타일을 설정합니다.
    private func setNavigationBar() {
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

    /// 네이버 지도 뷰를 초기화하고 화면에 추가합니다.
    private func configureMapView() {
        // 지도 뷰의 프레임을 view.frame으로 설정하면 전체를 덮게 됩니다.
        mapView = NMFMapView(frame: view.frame)
        view.addSubview(mapView)
        mapView.touchDelegate = self

        moveCamera(to: soongsilUniversityLocation, zoomLevel: 16.0)
    }

    /// 카메라를 특정 위치로 이동합니다.
    /// - Parameters:
    ///   - location: 이동할 위치의 위도 및 경도 (`NMGLatLng`)
    ///   - zoomLevel: 줌 레벨 (`Double`)
    private func moveCamera(to location: NMGLatLng, zoomLevel: Double) {
        let cameraUpdate = NMFCameraUpdate(
            position: NMFCameraPosition(location, zoom: zoomLevel)
        )
        mapView.moveCamera(cameraUpdate)
    }

    // MARK: - UISegmentedControl 설정

    /// 지도 상단에 UISegmentedControl을 추가합니다.
    private func setupSegmentedControl() {
        // segmented control에 들어갈 항목들을 설정합니다.
        let items = ["내 제휴", "전체"]
        mapSegmentedControl = UISegmentedControl(items: items)
        mapSegmentedControl.selectedSegmentIndex = 0
        mapSegmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)

        // 배경색 및 선택된 옵션의 색상, 곡률 반경 설정
        mapSegmentedControl.backgroundColor = .white
        mapSegmentedControl.selectedSegmentTintColor = EATSSUDesignAsset.Color.Main.primary.color
        mapSegmentedControl.layer.cornerRadius = 50
        mapSegmentedControl.layer.masksToBounds = true

        // 텍스트 폰트
        let font = EATSSUDesignFontFamily.Pretendard.semiBold.font(size: 14)

        // 텍스트 속성 설정
        mapSegmentedControl.setTitleTextAttributes(
            [
                .foregroundColor: UIColor.white,
                .font: font,
            ],
            for: .selected
        )
        mapSegmentedControl.setTitleTextAttributes(
            [
                .foregroundColor: UIColor.black,
                .font: font,
            ],
            for: .normal
        )

        // 각 Segment의 넓이를 지정하는 대신, 전체 컨트롤의 넓이를 145로 지정합니다.
        view.addSubview(mapSegmentedControl)
        mapSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(145)
        }

        // 혹시 지도 뷰가 segmented control 위에 올 수 있으므로 순서를 보장합니다.
        view.bringSubviewToFront(mapSegmentedControl)
    }

    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        // segmented control의 값이 변경되었을 때 처리할 코드를 작성합니다.
        #if DEBUG
            print("Selected segment index: \(sender.selectedSegmentIndex)")
        #endif

        // 예시: 선택된 인덱스에 따라 지도 스타일 변경 등
        // if sender.selectedSegmentIndex == 0 { ... } else { ... }
    }

    // MARK: - 마커 설정

    /// 특정 위치에 마커를 추가합니다.
    /// - Parameters:
    ///   - location: 마커를 추가할 위치 (`NMGLatLng`)
    ///   - title: 마커의 데이터 (`String`)
    ///   - leftText: 마커 왼쪽 텍스트 (`String`)
    ///   - rightText: 마커 오른쪽 텍스트 (`String`)
    /// 특정 위치에 마커를 추가합니다.
    private func addMarker(at location: NMGLatLng, leftText: String, rightText: String, markerData: MarkerData) {
        let marker = ESMarker(
            position: location,
            leftText: leftText,
            rightText: rightText,
            touchHandler: { (_: NMFOverlay) -> Bool in
                #if DEBUG
                    print("마커가 탭되었습니다!")
                #endif
                self.presentMarkerDetailFloatingPanel(with: markerData)
                return true
            },
            markerData: markerData
        )
        marker.marker.mapView = mapView
        esMarkers.append(marker)
    }

    /// 숭실대학교 위치에 마커를 추가합니다.
    private func addSoongsilMarker() {
        let soongsilMarker = ESMarker(
            position: soongsilUniversityLocation,
            leftText: "숭실대학교",
            rightText: "Soongsil Univ",
            touchHandler: { (_: NMFOverlay) -> Bool in
                #if DEBUG
                    print("마커가 탭되었습니다!")
                #endif
                self.presentMarkerDetailFloatingPanel(with: .init(title: "숭실대학교", description: "EATSSU의 서비스 지역"))
                return true
            },
            markerData: MarkerData(title: "숭실대학교", description: "EATSSU의 서비스 지역")
        )
        soongsilMarker.marker.mapView = mapView
        esMarkers.append(soongsilMarker)
    }

    // MARK: - 상세정보 표시

    /// `MarkerDetailViewController`를 `UISheetPresentationController`로 표시하는 메서드
    /// - Parameter data: 마커에 대한 데이터 (`MarkerData`)
    private func presentMarkerDetailFloatingPanel(with data: MarkerData) {
        // 상세정보를 표시할 컨텐츠 뷰 컨트롤러 생성
        let detailVC = MarkerDetailViewController()
        detailVC.markerData = data

        // FloatingPanelController가 없으면 생성 (한 번만 생성해 재사용할 수 있음)
        if floatingPanelController == nil {
            floatingPanelController = FloatingPanelController()
            floatingPanelController?.delegate = self
            // 배경의 터치 이벤트가 FloatingPanel에 가로채지 않도록 설정
//            floatingPanelController?.backgroundView?.isUserInteractionEnabled = false

            // 추가적으로 FloatingPanel의 레이아웃이나 외관을 커스터마이징할 수 있음
            // 예) floatingPanelController?.surfaceView.grabberHandle.isHidden = false
        }

        // 컨텐츠 뷰 컨트롤러 갱신
        floatingPanelController?.set(contentViewController: detailVC)

        // FloatingPanel이 아직 부모에 추가되지 않았다면, 현재 뷰 컨트롤러에 추가
        if floatingPanelController?.parent == nil {
            floatingPanelController?.addPanel(toParent: self)
        }
    }
}

// MARK: - NMFMapViewTouchDelegate (지도 터치 이벤트)

extension MapViewController: NMFMapViewTouchDelegate {
    /// 사용자가 지도에서 단일 탭을 했을 때 호출됩니다.
    /// - Parameters:
    ///   - latlng: 사용자가 탭한 위치 (`NMGLatLng`)
    ///   - point: 터치된 화면 좌표 (`CGPoint`)
    func mapView(_: NMFMapView, didTapMap latlng: NMGLatLng, point _: CGPoint) {
        #if DEBUG
            print("탭: \(latlng.lat), \(latlng.lng)")
        #endif
    }

    /// 사용자가 지도에서 길게 눌렀을 때 호출됩니다.
    /// - Parameters:
    ///   - latlng: 사용자가 길게 누른 위치 (`NMGLatLng`)
    ///   - point: 터치된 화면 좌표 (`CGPoint`)
    func mapView(_: NMFMapView, didLongTapMap latlng: NMGLatLng, point _: CGPoint) {
        #if DEBUG
            print("롱 탭: \(latlng.lat), \(latlng.lng)")
        #endif
    }
}

extension MapViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidRemove(_: FloatingPanelController) {
        // 패널이 제거되었을 때 필요한 처리가 있다면 구현합니다.
        floatingPanelController = nil
    }
}
