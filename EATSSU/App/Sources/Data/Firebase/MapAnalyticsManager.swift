//
//  MapAnalyticsManager.swift
//  EATSSU
//
//  Created by 황상환 on 9/13/25.
//

import FirebaseAnalytics
import PostHog

/// 지도 화면에서 발생하는 주요 이벤트를 Firebase Analytics에 로깅하는 담당자
final class MapAnalyticsManager {
    
    // MARK: - Singleton
    
    static let shared = MapAnalyticsManager()
    private init() {}
    
    // MARK: - Event & Parameter Keys
    
    private enum Event {
        static let clickMap = "click_map"
        static let clickMapMine = "click_map_mine"
        static let clickPartnerRestaurant = "click_partner_restaurant"
    }
    
    private enum Parameter {
        static let college = "college"
        static let major = "major"
        static let partnerRestaurantId = "partner_restaurant_id"
    }
    
    // MARK: - Logging Methods

    /**
     #1 하단 탭바에서 '지도'를 클릭했을 때 호출
     */
    func logClickMap() {
        Analytics.logEvent(Event.clickMap, parameters: nil)
        PostHogSDK.shared.capture(Event.clickMap)
    }
    
    /**
     #2 지도 화면에서 '내 제휴' (또는 학과명) 버튼을 클릭했을 때 호출
     - Parameter collegeId: 사용자의 단과대 ID
     - Parameter majorId: 사용자의 학과 ID
     */
    func logClickMapMine(collegeId: Int, majorId: Int) {
        let parameters: [String: Any] = [
            Parameter.college: collegeId,
            Parameter.major: majorId
        ]
        Analytics.logEvent(Event.clickMapMine, parameters: parameters)
        PostHogSDK.shared.capture(Event.clickMapMine, properties: parameters)
    }

    /**
     #3 지도에서 특정 제휴 매장 마커를 클릭했을 때 호출
     - Parameter collegeId: 사용자의 단과대 ID
     - Parameter majorId: 사용자의 학과 ID
     - Parameter partnerId: 클릭된 제휴 정보 ID
     */
    func logClickPartnerRestaurant(collegeId: Int?, majorId: Int?, partnerId: Int) {
        var parameters: [String: Any] = [
            Parameter.partnerRestaurantId: partnerId
        ]
        
        if let collegeId = collegeId {
            parameters[Parameter.college] = collegeId
        }
        
        if let majorId = majorId {
            parameters[Parameter.major] = majorId
        }
        
        Analytics.logEvent(Event.clickPartnerRestaurant, parameters: parameters)
        PostHogSDK.shared.capture(Event.clickPartnerRestaurant, properties: parameters)
    }
}
