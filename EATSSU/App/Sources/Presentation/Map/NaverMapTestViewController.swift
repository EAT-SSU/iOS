//
//  NaverMapTestViewController.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 6/24/25.
//

import UIKit
import NMapsMap

final class NaverMapTestViewController: UIViewController {

    private let mapView = NMFNaverMapView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupMapView()
    }

    private func setupMapView() {
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

