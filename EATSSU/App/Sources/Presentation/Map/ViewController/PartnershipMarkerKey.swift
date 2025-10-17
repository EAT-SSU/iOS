//
//  PartnershipMarkerKey.swift
//  EATSSU
//
//  Created by 황상환 on 10/4/25.
//

import Foundation
import NMapsMap

// MARK: - PartnershipMarkerKey

/// 제휴점 마커 클러스터링을 위한 고유 키 클래스
final class PartnershipMarkerKey: NSObject, NMCClusteringKey {
    
    // MARK: - Properties
    
    /// 제휴점 고유 식별자
    let identifier: Int
    
    /// 제휴점 위치 좌표
    let position: NMGLatLng
    
    // MARK: - Initialization
    
    init(identifier: Int, position: NMGLatLng) {
        self.identifier = identifier
        self.position = position
        super.init()
    }
    
    // MARK: - NSObject Override
    
    /// 두 마커 키의 동일성 비교
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? PartnershipMarkerKey else {
            return false
        }
        if self === other {
            return true
        }
        return other.identifier == self.identifier
    }
    
    /// 해시값 반환 (identifier 기반)
    override var hash: Int {
        return self.identifier
    }
    
    // MARK: - NSCopying
    
    /// 마커 키 복사 메서드 (NSCopying 프로토콜 준수)
    func copy(with zone: NSZone? = nil) -> Any {
        return PartnershipMarkerKey(identifier: self.identifier, position: self.position)
    }
}
