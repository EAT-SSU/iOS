//
//  PartnershipLeafMarkerUpdater.swift
//  EATSSU
//
//  Created by 황상환 on 10/4/25.
//

import UIKit
import NMapsMap
import EATSSUDesign

// MARK: - PartnershipLeafMarkerUpdater

/// 개별 제휴점 마커(Leaf Marker)의 스타일과 데이터를 업데이트하는 클래스
final class PartnershipLeafMarkerUpdater: NMCDefaultLeafMarkerUpdater {
    
    // MARK: - Properties
    
    /// 지도에 표시할 제휴점 데이터 목록
    var partnerships: [PartnershipDTO] = []
    
    /// 마커 탭 시 호출될 클로저
    var onMarkerTap: ((PartnershipDTO) -> Void)?
    
    // MARK: - Override Methods
    
    /// 개별 마커가 지도에 표시될 때 호출되어 마커의 아이콘과 캡션을 설정
    override func updateLeafMarker(_ info: NMCLeafMarkerInfo, _ marker: NMFMarker) {
        super.updateLeafMarker(info, marker)
        
        guard let key = info.key as? PartnershipMarkerKey else { return }
        
        guard let partnership = findPartnership(for: key) else { return }
        
        configureMarkerIcon(marker, with: partnership)
        
        // 마커 탭 핸들러 설정
        marker.touchHandler = { [weak self] _ -> Bool in
            self?.onMarkerTap?(partnership)
            return true
        }
    }
    
    // MARK: - Private Methods
    
    /// 마커 키에 해당하는 제휴점 데이터 검색
    private func findPartnership(for key: PartnershipMarkerKey) -> PartnershipDTO? {
        return partnerships.first { partnership in
            NMGLatLng(lat: partnership.latitude, lng: partnership.longitude) == key.position
        }
    }
    
    /// 마커 아이콘 설정
    private func configureMarkerIcon(_ marker: NMFMarker, with partnership: PartnershipDTO) {
        let iconImage = makeMarkerImage(
            type: partnership.restaurantType,
            title: partnership.storeName
        )
        marker.iconImage = NMFOverlayImage(image: iconImage)
        marker.width = iconImage.size.width
        marker.height = iconImage.size.height
    }
    
    // configureMarkerCaption 메서드는 이제 사용하지 않으므로 제거해도 됨
    
    /// 제휴점 타입에 따른 마커 이미지 생성
    private func makeMarkerImage(type: String, title: String) -> UIImage {
        let icon = iconForRestaurantType(type)
        let markerView = MapMarkerView(icon: icon, title: title)
        markerView.layoutIfNeeded()
        markerView.frame = CGRect(origin: .zero, size: markerView.intrinsicContentSize)
        return markerView.toImage()
    }
    
    /// 제휴점 타입에 따른 아이콘 이미지 반환
    private func iconForRestaurantType(_ type: String) -> UIImage? {
        switch type {
        case "RESTAURANT":
            return EATSSUDesignAsset.Images.restaurantPin.image
        case "CAFE":
            return EATSSUDesignAsset.Images.cafePin.image
        case "PUB":
            return EATSSUDesignAsset.Images.pubPin.image
        default:
            return EATSSUDesignAsset.Images.restaurantPin.image
        }
    }
}
