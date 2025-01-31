//
//  MapViewController.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 1/28/25.
//

import EATSSUDesign
import NMapsMap
import UIKit

/// `MapViewController`는 네이버 지도를 표시하고, 마커를 추가하는 역할을 합니다.
final class MapViewController: BaseViewController, NMFMapViewTouchDelegate {
    /// 네이버 지도 뷰
    private var mapView: NMFMapView!

    /// 숭실대학교 위치 (위도, 경도)
    private let soongsilUniversityLocation = NMGLatLng(lat: 37.496389, lng: 126.957222)

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureMapView()
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

    // MARK: - 마커 설정

    /// 숭실대학교 위치에 마커를 추가합니다.
    private func addSoongsilMarker() {
        let soongsilMarker = ESMarker(
            position: soongsilUniversityLocation,
            data: "Soongsil Univ",
            leftText: "숭실대학교",
            rightText: "Soongsil Univ"
        )
        soongsilMarker.marker.mapView = mapView
    }
}

// MARK: - NMFMapViewTouchDelegate (지도 터치 이벤트)

extension MapViewController {
    /// 사용자가 지도에서 단일 탭을 했을 때 호출됩니다.
    /// - Parameters:
    ///   - latlng: 사용자가 탭한 위치 (`NMGLatLng`)
    ///   - point: 터치된 화면 좌표 (`CGPoint`)
    func mapView(_: NMFMapView, didTapMap latlng: NMGLatLng, point _: CGPoint) {
        #if DEBUG
            print("탭: \(latlng.lat), \(latlng.lng)")
        #endif

        addMarker(at: latlng, title: "Tapped Location", leftText: "Tapped Marker", rightText: "Here is the location")
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

    /// 특정 위치에 마커를 추가합니다.
    /// - Parameters:
    ///   - location: 마커를 추가할 위치 (`NMGLatLng`)
    ///   - title: 마커의 데이터 (`String`)
    ///   - leftText: 마커 왼쪽 텍스트 (`String`)
    ///   - rightText: 마커 오른쪽 텍스트 (`String`)
    private func addMarker(at location: NMGLatLng, title: String, leftText: String, rightText: String) {
        let marker = ESMarker(
            position: location,
            data: title,
            leftText: leftText,
            rightText: rightText
        )
        marker.marker.mapView = mapView
    }
}
