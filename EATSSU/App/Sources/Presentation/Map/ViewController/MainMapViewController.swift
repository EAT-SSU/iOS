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

final class MainMapViewController: UIViewController, CLLocationManagerDelegate {

    private let mainView = MainMapView()
    private let locationManager = CLLocationManager()
    private var currentDepartmentName: String?
    
    private let partnershipProvider = MoyaProvider<PartnershipRouter>(session: Session(interceptor: AuthInterceptor.shared))
    private let myProvider = MoyaProvider<MyRouter>(session: Session(interceptor: AuthInterceptor.shared))

    private var markers: [NMFMarker] = []

    override func loadView() {
        self.view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
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
        
        fetchDepartmentAndUpdateButton()
        fetchPartnerships()
    }

    @objc private func didTapWhole() {
        mainView.selectWhole(true)
        fetchPartnerships()
    }

    @objc private func didTapMyOnly() {
        if currentDepartmentName?.isEmpty ?? true {
            presentNoDepartmentSheet()
            return
        }

        mainView.selectWhole(false)
        fetchMyPartnerships()
    }
    
    private func presentNoDepartmentSheet() {
        let sheetVC = NoDepartmentSheetViewController()
        present(sheetVC, animated: true)
    }

    @objc private func didTapHeart() {
        print("하트 버튼 클릭됨")
    }
    
    func reloadContent() {
        fetchDepartmentAndUpdateButton()
        if mainView.wholeButton.backgroundColor == EATSSUDesignAsset.Color.Main.primary.color {
            fetchPartnerships()
        } else {
            fetchMyPartnerships()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if let location = manager.location?.coordinate {
                let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: location.latitude, lng: location.longitude), zoomTo: 15.5)
                mainView.mapView.mapView.moveCamera(cameraUpdate)
            }
        default:
            break
        }
    }

    private func displayMarkers(_ partnerships: [PartnershipDTO]) {
        markers.forEach { $0.mapView = nil }
        markers.removeAll()

        var latSum: Double = 0
        var lngSum: Double = 0

        for partnership in partnerships {
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: partnership.latitude, lng: partnership.longitude)
            
            let markerImage = makeMarkerImage(type: partnership.restaurantType, title: partnership.storeName)
            marker.iconImage = NMFOverlayImage(image: markerImage)
            marker.width = CGFloat(UInt32(markerImage.size.width))
            marker.height = CGFloat(UInt32(markerImage.size.height))
            
            marker.touchHandler = { [weak self] _ in
                let vc = PartnershipDetailSheetViewController(
                    storeName: partnership.storeName,
                    restaurantType: partnership.restaurantType,
                    partnershipInfos: partnership.partnershipInfos
                )
                self?.present(vc, animated: true)
                return true
            }
            
            marker.mapView = mainView.mapView.mapView
            markers.append(marker)

            latSum += partnership.latitude
            lngSum += partnership.longitude
        }

        if !partnerships.isEmpty {
            let centerLat = latSum / Double(partnerships.count)
            let centerLng = lngSum / Double(partnerships.count)
            let center = NMGLatLng(lat: centerLat, lng: centerLng)

            let cameraUpdate = NMFCameraUpdate(scrollTo: center, zoomTo: 15.5)
            mainView.mapView.mapView.moveCamera(cameraUpdate)
        }
    }

    private func makeMarkerImage(type: String, title: String) -> UIImage {
        let icon: UIImage?

        switch type {
        case "RESTAURANT":
            icon = EATSSUDesignAsset.Images.restaurantPin.image
        case "CAFE":
            icon = EATSSUDesignAsset.Images.cafePin.image
        case "PUB":
            icon = EATSSUDesignAsset.Images.pubPin.image
        default:
            icon = EATSSUDesignAsset.Images.restaurantPin.image
        }

        let markerView = MapMarkerView(icon: icon, title: title)
        markerView.setNeedsLayout()
        markerView.layoutIfNeeded()

        let fittingSize = markerView.systemLayoutSizeFitting(
            CGSize(width: UIView.layoutFittingCompressedSize.width, height: 24),
            withHorizontalFittingPriority: .fittingSizeLevel,
            verticalFittingPriority: .required
        )

        markerView.frame = CGRect(origin: .zero, size: fittingSize)
        return markerView.toImage()

    }

    // MARK: - Network
    // 전체 제휴
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
    // 학과 제휴
    private func fetchDepartmentAndUpdateButton() {
        myProvider.request(.getDepartment) { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try response.map(BaseResponse<GetDepartmentResponse>.self)
                    let department = decoded.result?.departmentName ?? ""
                    self?.currentDepartmentName = department // 저장
                    let buttonTitle = department.isEmpty ? "내 제휴" : department
                    self?.mainView.myOnlyButton.setTitle(buttonTitle, for: .normal)
                } catch {
                    print("학과 응답 디코딩 실패: \(error)")
                    self?.currentDepartmentName = nil
                    self?.mainView.myOnlyButton.setTitle("내 제휴", for: .normal)
                }
            case .failure(let error):
                print("학과 API 요청 실패: \(error)")
                self?.currentDepartmentName = nil
                self?.mainView.myOnlyButton.setTitle("내 제휴", for: .normal)
            }
        }
    }
    
    private func fetchMyPartnerships() {
        myProvider.request(.getMyPartnerships) { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try response.map(BaseResponse<[PartnershipDTO]>.self)
                    guard let partnerships = decoded.result else { return }
                    self?.displayMarkers(partnerships)
                } catch {
                    print("유저 제휴 디코딩 실패: \(error)")
                }
            case .failure(let error):
                print("유저 제휴 네트워크 오류: \(error)")
            }
        }
    }

}
