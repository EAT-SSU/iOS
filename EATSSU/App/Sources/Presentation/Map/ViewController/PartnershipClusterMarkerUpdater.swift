//
//  PartnershipClusterMarkerUpdater.swift
//  EATSSU
//
//  Created by 황상환 on 10/4/25.
//

import UIKit
import NMapsMap
import EATSSUDesign

// MARK: - PartnershipClusterMarkerUpdater

/// 클러스터 마커의 스타일을 업데이트하는 클래스
final class PartnershipClusterMarkerUpdater: NMCDefaultClusterMarkerUpdater {
    
    // MARK: - Properties
    
    /// 클러스터 이미지 생성을 위한 ViewController 참조
    weak var viewController: MainMapViewController?
    
    // MARK: - Override Methods
    
    /// 클러스터 마커가 지도에 표시될 때 호출되어 원형 이미지로 스타일 설정
    override func updateClusterMarker(_ info: NMCClusterMarkerInfo, _ marker: NMFMarker) {
        super.updateClusterMarker(info, marker)
        
        guard let image = viewController?.makeClusterImage(count: info.size) else { return }
        
        marker.iconImage = NMFOverlayImage(image: image)
        marker.width = 40
        marker.height = 40
    }
}
