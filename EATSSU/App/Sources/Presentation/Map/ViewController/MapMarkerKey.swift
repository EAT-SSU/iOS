//
//  MapMarkerKey.swift
//  EATSSU
//
//  Created by 황상환 on 10/4/25.
//

import Foundation
import NMapsMap

/// 마커 클러스터링을 위한 고유 키 클래스
final class MapMarkerKey: NSObject, NMCClusteringKey {

    /// 마커 목록 내 인덱스
    let identifier: Int
    let position: NMGLatLng

    init(identifier: Int, position: NMGLatLng) {
        self.identifier = identifier
        self.position = position
        super.init()
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? MapMarkerKey else { return false }
        if self === other { return true }
        return other.identifier == self.identifier
    }

    override var hash: Int { identifier }

    func copy(with zone: NSZone? = nil) -> Any {
        MapMarkerKey(identifier: identifier, position: position)
    }
}
