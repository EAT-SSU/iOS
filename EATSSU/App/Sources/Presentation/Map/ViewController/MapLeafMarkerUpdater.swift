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

    /// 줌/팬으로 같은 마커가 반복 노출될 때 재래스터화를 피하기 위한 캐시 (identifier 기준)
    private var imageCache: [Int: UIImage] = [:]

    override func updateLeafMarker(_ info: NMCLeafMarkerInfo, _ marker: NMFMarker) {
        super.updateLeafMarker(info, marker)

        guard let key = info.key as? MapMarkerKey,
              items.indices.contains(key.identifier) else { return }
        let item = items[key.identifier]

        let iconImage: UIImage
        if let cached = imageCache[key.identifier] {
            iconImage = cached
        } else {
            let markerView = MapMarkerView(icon: item.icon, title: item.title)
            markerView.layoutIfNeeded()
            markerView.frame = CGRect(origin: .zero, size: markerView.intrinsicContentSize)
            iconImage = markerView.toImage()
            imageCache[key.identifier] = iconImage
        }

        marker.iconImage = NMFOverlayImage(image: iconImage)
        marker.width = iconImage.size.width
        marker.height = iconImage.size.height

        marker.touchHandler = { _ -> Bool in
            item.onTap()
            return true
        }
    }
}
