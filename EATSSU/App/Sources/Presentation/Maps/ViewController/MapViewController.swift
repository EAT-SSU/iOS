//
//  MapViewController.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 1/28/25.
//

import UIKit

import EATSSUDesign

import NMapsMap

final class MapViewController: BaseViewController, NMFMapViewTouchDelegate {
    private var mapView: NMFMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()

        mapView = NMFMapView(frame: view.frame)
        view.addSubview(mapView)

        // Sample marker at NAVER 1984 location
        let sampleMarker = ESMarker(
            position: NMGLatLng(lat: 37.3595704, lng: 127.105399),
            data: "Sample Data",
            leftText: "NAVER",
            rightText: "1984"
        )
        sampleMarker.marker.mapView = mapView

        mapView.touchDelegate = self
    }

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
}

extension MapViewController {
    func mapView(_: NMFMapView, didTapMap latlng: NMGLatLng, point _: CGPoint) {
        #if DEBUG
            print("탭: \(latlng.lat), \(latlng.lng)")
        #endif

        let marker = ESMarker(
            position: NMGLatLng(lat: latlng.lat, lng: latlng.lng),
            data: "Tapped Location",
            leftText: "Tapped",
            rightText: "Here"
        )
        marker.marker.mapView = mapView
    }

    func mapView(_: NMFMapView, didLongTapMap latlng: NMGLatLng, point _: CGPoint) {
        #if DEBUG
            print("롱 탭: \(latlng.lat), \(latlng.lng)")
        #endif
    }
}
