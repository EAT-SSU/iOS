//
//  MapViewController.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 1/28/25.
//

import UIKit

import EATSSUDesign
import EATSSUKit

import NMapsMap
import SnapKit

/// `MapViewController`는 네이버 지도를 표시하고, 마커를 추가하는 역할을 합니다.
final class MapViewController: BaseViewController {
    /// 네이버 지도 뷰
    private var mapView: NMFMapView!

    /// 지도 위에 추가할 UISegmentedControl
    private var mapSegmentedControl: UISegmentedControl!

    /// 숭실대학교 위치 (위도, 경도)
    private let soongsilUniversityLocation = NMGLatLng(lat: 37.496389, lng: 126.957222)

    /// 추가된 ESMarker들을 저장하는 배열
    private var esMarkers: [ESMarker] = []

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureMapView()
        setupSegmentedControl() // 여기서 segmented control을 추가합니다.
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
        let items = ["Option 1", "Option 2"]
        mapSegmentedControl = UISegmentedControl(items: items)
        mapSegmentedControl.selectedSegmentIndex = 0
        mapSegmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)

        // segmented control을 view의 서브뷰로 추가합니다.
        view.addSubview(mapSegmentedControl)
        mapSegmentedControl.translatesAutoresizingMaskIntoConstraints = false

        // Auto Layout을 이용해 지도 상단에 고정합니다.
        NSLayoutConstraint.activate([
            // safeArea의 상단에 8pt 간격을 두고 배치
            mapSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            mapSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mapSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])

        // 혹시 지도 뷰가 segmented control 위에 올 수 있으므로 bringSubviewToFront로 순서를 보장합니다.
        view.bringSubviewToFront(mapSegmentedControl)
    }

    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        // segmented control의 값이 변경되었을 때 처리할 코드를 작성합니다.
        print("Selected segment index: \(sender.selectedSegmentIndex)")

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
    private func addMarker(at location: NMGLatLng, leftText: String, rightText: String, markerData: MarkerData) {
        let marker = ESMarker(
            position: location,
            leftText: leftText,
            rightText: rightText,
            touchHandler: { (_: NMFOverlay) -> Bool in
                #if DEBUG
                    print("마커가 탭되었습니다!")
                #endif
                self.presentMarkerDetailModal(with: markerData)
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
                self.presentMarkerDetailModal(with: .init(title: "숭실대학교", description: "EATSSU의 서비스 지역"))
                return true
            },
            markerData: MarkerData(title: "숭실대학교", description: "EATSSU의 서비스 지역")
        )
        soongsilMarker.marker.mapView = mapView
        esMarkers.append(soongsilMarker)
    }

    // MARK: - Modal 표시

    /// `MarkerDetailViewController`를 표시하는 메서드
    /// - Parameter data: 마커에 대한 데이터 (`MarkerData`)
    private func presentMarkerDetailModal(with data: MarkerData) {
        let detailVC = MarkerDetailViewController()
        detailVC.markerData = data
        let navController = UINavigationController(rootViewController: detailVC)

        // 모달 스타일을 설정
        navController.modalPresentationStyle = .pageSheet

        // `UISheetPresentationController` 설정 (iOS 15+)
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium(), .large()] // 중간 크기와 큰 크기로 설정
            sheet.prefersGrabberVisible = true // 위로 드래그할 수 있도록 grabber 표시
            sheet.prefersEdgeAttachedInCompactHeight = true // 화면 하단에 고정
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }

        present(navController, animated: true, completion: nil)
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
