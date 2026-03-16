//
//  PromotionPopupDisplayData.swift
//  EATSSU
//
//  Created by jeongminji on 3/16/26.
//

import Foundation

/// 홈 프로모션 팝업 노출 여부를 관리하는 데이터
enum HomePromotionPopupDisplayData {
    
    // MARK: - UserDefaults Key
    
    private static let hideKey = "shouldHidePromotionPopupForever_v1"
    
    // MARK: - Properties
    
    /// 팝업을 보여줄지 여부
    static var shouldShow: Bool {
        return !UserDefaults.standard.bool(forKey: hideKey)
    }
    
    // MARK: - Methods
    
    /// 팝업을 영구적으로 숨김
    static func hideForever() {
        UserDefaults.standard.set(true, forKey: hideKey)
    }
    
    /// 숨김 상태 초기화 (디버그 / 테스트용)
    static func reset() {
        UserDefaults.standard.removeObject(forKey: hideKey)
    }
}
