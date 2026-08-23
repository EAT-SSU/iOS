//
//  MapLeafMarkerUpdater.swift
//  EATSSU
//
//  Created by 황상환 on 10/4/25.
//

import UIKit
import NMapsMap

/// 개별 마커(Leaf Marker)의 아이콘/탭 핸들러를 설정하는 클래스
final class MapLeafMarkerUpdater: NMCDefaultLeafMarkerUpdater {

    var items: [MapMarkerItem] = []

    override func updateLeafMarker(_ info: NMCLeafMarkerInfo, _ marker: NMFMarker) {
        super.updateLeafMarker(info, marker)

        guard let key = info.key as? MapMarkerKey,
              items.indices.contains(key.identifier) else { return }
        let item = items[key.identifier]

        let markerView = MapMarkerView(icon: item.icon, title: item.title)
        markerView.layoutIfNeeded()
        markerView.frame = CGRect(origin: .zero, size: markerView.intrinsicContentSize)
        let iconImage = markerView.toImage()

        marker.iconImage = NMFOverlayImage(image: iconImage)
        marker.width = iconImage.size.width
        marker.height = iconImage.size.height

        marker.touchHandler = { _ -> Bool in
            item.onTap()
            return true
        }
    }
}
