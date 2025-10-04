//
//  ItemKey.swift
//  EATSSU
//
//  Created by 황상환 on 10/4/25.
//

// ItemKey.swift

import Foundation
import NMapsMap

final class ItemKey: NSObject, NMCClusteringKey {
    let identifier: Int
    let position: NMGLatLng

    init(identifier: Int, position: NMGLatLng) {
        self.identifier = identifier
        self.position = position
        super.init()
    }

    // `isEqual`과 `hash`는 고유한 identifier를 기준으로 비교하도록 합니다.
    override func isEqual(_ o: Any?) -> Bool {
        guard let o = o as? ItemKey else {
            return false
        }
        if self === o {
            return true
        }
        return o.identifier == self.identifier
    }

    override var hash: Int {
        return self.identifier
    }

    // NSCopying 프로토콜을 준수하기 위해 copy 메서드를 구현합니다.
    func copy(with zone: NSZone? = nil) -> Any {
        return ItemKey(identifier: self.identifier, position: self.position)
    }
}
