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

final class MainMapViewController: UIViewController {

    private let mainView = MainMapView()
    
    private let partnershipProvider = MoyaProvider<PartnershipRouter>(session: Session(interceptor: AuthInterceptor.shared))
    private var markers: [NMFMarker] = []

    override func loadView() {
        self.view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "제휴 지도"

        // 배경색 채우기
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

        mainView.wholeButton.addTarget(self, action: #selector(didTapWhole), for: .touchUpInside)
        mainView.myOnlyButton.addTarget(self, action: #selector(didTapMyOnly), for: .touchUpInside)
        mainView.heartButton.addTarget(self, action: #selector(didTapHeart), for: .touchUpInside)
        
        fetchPartnerships()
    }

    @objc private func didTapWhole() {
        mainView.selectWhole(true)
        print("전체 보기")
    }

    @objc private func didTapMyOnly() {
        mainView.selectWhole(false)
        print("내 제휴 보기")
    }

    @objc private func didTapHeart() {
        print("하트 버튼 클릭됨")
    }
    
    private func displayMarkers(_ partnerships: [PartnershipDTO]) {
        markers.forEach { $0.mapView = nil }
        markers.removeAll()

        var latSum: Double = 0
        var lngSum: Double = 0

        for partnership in partnerships {
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: partnership.latitude, lng: partnership.longitude)
            
            let markerImage = makeMarkerImage(title: partnership.storeName)
            marker.iconImage = NMFOverlayImage(image: markerImage)
            marker.width = CGFloat(UInt32(markerImage.size.width))
            marker.height = CGFloat(UInt32(markerImage.size.height))
            
            marker.mapView = mainView.mapView.mapView
            markers.append(marker)

            latSum += partnership.latitude
            lngSum += partnership.longitude
        }

        if !partnerships.isEmpty {
            let centerLat = latSum / Double(partnerships.count)
            let centerLng = lngSum / Double(partnerships.count)
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: centerLat, lng: centerLng))
            mainView.mapView.mapView.moveCamera(cameraUpdate)
        }
    }
    
    private func makeMarkerImage(title: String) -> UIImage {
        let label = UILabel()
        label.text = "🍻 \(title)"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        label.backgroundColor = UIColor(red: 72/255, green: 194/255, blue: 196/255, alpha: 1) // #48C2C4
        label.textAlignment = .center
        label.layer.cornerRadius = 14
        label.layer.masksToBounds = true
        label.sizeToFit()
        
        let padding: CGFloat = 10
        let imageSize = CGSize(width: label.frame.width + padding * 2, height: label.frame.height + padding)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        label.frame = CGRect(x: padding, y: 0, width: label.frame.width, height: label.frame.height)
        label.drawHierarchy(in: label.frame, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }

    
    // MARK: - Network

    private func fetchPartnerships() {
        partnershipProvider.request(.getAllPartnerships) { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try response.map(BaseResponse<[PartnershipDTO]>.self)
                    guard let partnerships = decoded.result else { return }
                    self?.displayMarkers(partnerships)
                } catch {
                    print("Decoding 실패: \(error.localizedDescription)")
                }
            case .failure(let error):
                print("네트워크 오류: \(error.localizedDescription)")
            }
        }
    }
}
