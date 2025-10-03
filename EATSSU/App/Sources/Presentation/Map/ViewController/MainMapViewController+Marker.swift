//
//  MainMapViewController+Marker.swift
//  EATSSU
//
//  Created by 황상환 on 10/4/25.
//

import UIKit
import NMapsMap

import EATSSUDesign

// MARK: - Marker Management

extension MainMapViewController {
    
    func displayMarkers(_ partnerships: [PartnershipDTO]) {
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

                if self.currentMapMode == .myOnly {
                    if let partnerId = partnership.partnershipInfos.first?.id {
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
    
    func makeMarkerImage(type: String, title: String) -> UIImage {
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
}
