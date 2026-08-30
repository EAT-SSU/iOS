//
//  MapClusterMarkerUpdater.swift
//  EATSSU
//
//  Created by 황상환 on 10/4/25.
//

import UIKit
import NMapsMap

/// 클러스터 마커를 개수 표시 원형 이미지로 그리는 클래스
final class MapClusterMarkerUpdater: NMCDefaultClusterMarkerUpdater {

    weak var viewController: MainMapViewController?

    /// 클러스터 원 색상. displayMarkers 시점에 고정되어 늦은 응답 동안 필터 색과 섞이지 않는다
    var color: UIColor = .primary

    override func updateClusterMarker(_ info: NMCClusterMarkerInfo, _ marker: NMFMarker) {
        super.updateClusterMarker(info, marker)

        marker.captionText = ""

        guard let image = viewController?.makeClusterImage(count: info.size, color: color) else { return }

        marker.iconImage = NMFOverlayImage(image: image)
        marker.width = 40
        marker.height = 40
    }
}
