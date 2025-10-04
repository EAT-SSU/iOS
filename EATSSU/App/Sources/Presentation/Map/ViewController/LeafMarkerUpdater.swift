//
//  LeafMarkerUpdater.swift
//  EATSSU
//
//  Created by 황상환 on 10/4/25.
//

// LeafMarkerUpdater.swift

import UIKit
import NMapsMap
import EATSSUDesign

final class LeafMarkerUpdater: NMCDefaultLeafMarkerUpdater {
    
    // 외부에서 제휴점 데이터 목록을 받아 저장할 프로퍼티
    var partnerships: [PartnershipDTO] = []

    // 개별 마커(leaf)가 지도에 표시될 때마다 호출되는 메서드
    override func updateLeafMarker(_ info: NMCLeafMarkerInfo, _ marker: NMFMarker) {
        super.updateLeafMarker(info, marker)

        // info.key를 우리가 만든 ItemKey 타입으로 변환합니다.
        if let key = info.key as? ItemKey {
            
            // ItemKey의 위치 정보와 일치하는 제휴점 데이터를 찾습니다.
            if let partnership = partnerships.first(where: {
                NMGLatLng(lat: $0.latitude, lng: $0.longitude) == key.position
            }) {
                
                // 마커의 아이콘 이미지를 설정합니다. (MapMarkerView 사용)
                let iconImage = makeMarkerImage(type: partnership.restaurantType, title: partnership.storeName)
                marker.iconImage = NMFOverlayImage(image: iconImage)
                marker.width = iconImage.size.width
                marker.height = iconImage.size.height

                // 마커의 캡션을 제휴점 이름으로 설정합니다.
                marker.captionText = partnership.storeName
                marker.captionColor = .black
                marker.captionHaloColor = .white
            }
        }
    }
    
    // 개별 마커 이미지를 생성하는 헬퍼 메서드
    private func makeMarkerImage(type: String, title: String) -> UIImage {
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
