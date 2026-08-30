//
//  MapAnalyticsManager.swift
//  EATSSU
//
//  Created by 황상환 on 9/13/25.
//

/// 지도 화면에서 발생하는 주요 이벤트를 Firebase Analytics에 로깅하는 담당자
final class MapAnalyticsManager {

    // MARK: - Singleton

    static let shared = MapAnalyticsManager()
    private init() {}

    // MARK: - Event & Parameter Keys

    private enum Event {
        static let clickMap = "click_map"
        static let clickMapAll = "click_map_all"
        static let clickMapMine = "click_map_mine"
        static let clickMapFestival = "click_map_festival"
        static let clickPartnerRestaurant = "click_partner_restaurant"
        static let clickMapGoodPrice = "click_map_good_price"
        static let clickGoodPriceCategory = "click_good_price_category"
        static let clickGoodPriceStore = "click_good_price_store"
    }

    private enum Parameter {
        static let college = "college"
        static let major = "major"
        static let defaultType = "default_type"
        static let partnerRestaurantId = "partner_restaurant_id"
        static let category = "category"
        static let goodPriceStoreId = "good_price_store_id"
    }

    // MARK: - Logging Methods

    /**
     #1 하단 탭바에서 '지도'를 클릭했을 때 호출
     - Parameter collegeId: 사용자의 단과대 ID (학과 미설정 시 nil)
     - Parameter majorId: 사용자의 학과 ID (학과 미설정 시 nil)
     - Note: 지도는 항상 학교 제휴 > 전체 필터로 진입하므로 default_type은 "general" 고정 (대시보드 호환용 파라미터 유지)
     */
    func logClickMap(collegeId: Int?, majorId: Int?) {
        AnalyticsService.logEvent(
            Event.clickMap,
            parameters: makeParameters(collegeId: collegeId, majorId: majorId, extra: [
                Parameter.defaultType: "general"
            ])
        )
    }

    /**
     #2 지도 화면에서 '전체' 버튼을 클릭했을 때 호출
     */
    func logClickMapAll(collegeId: Int?, majorId: Int?) {
        AnalyticsService.logEvent(
            Event.clickMapAll,
            parameters: makeParameters(collegeId: collegeId, majorId: majorId)
        )
    }

    /**
     #3 지도 화면에서 '내 제휴' (또는 학과명) 버튼을 클릭했을 때 호출
     - Parameter collegeId: 사용자의 단과대 ID
     - Parameter majorId: 사용자의 학과 ID
     */
    func logClickMapMine(collegeId: Int, majorId: Int) {
        AnalyticsService.logEvent(Event.clickMapMine, parameters: [
            Parameter.college: collegeId,
            Parameter.major: majorId
        ])
    }

    /**
     #4 지도 화면에서 '축제' 버튼을 클릭했을 때 호출
     */
    func logClickMapFestival(collegeId: Int?, majorId: Int?) {
        AnalyticsService.logEvent(
            Event.clickMapFestival,
            parameters: makeParameters(collegeId: collegeId, majorId: majorId)
        )
    }

    /**
     #5 지도에서 특정 제휴 매장 마커를 클릭했을 때 호출
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

        AnalyticsService.logEvent(Event.clickPartnerRestaurant, parameters: parameters)
    }

    /**
     #6 지도 화면에서 '착한 가격' 탭을 클릭했을 때 호출
     */
    func logClickMapGoodPrice(collegeId: Int?, majorId: Int?) {
        AnalyticsService.logEvent(
            Event.clickMapGoodPrice,
            parameters: makeParameters(collegeId: collegeId, majorId: majorId)
        )
    }

    /**
     #7 착한가격 탭에서 업종 필터를 클릭했을 때 호출
     - Parameter category: 선택한 업종 (전체는 "ALL")
     */
    func logClickGoodPriceCategory(category: GoodPriceCategory) {
        AnalyticsService.logEvent(Event.clickGoodPriceCategory, parameters: [
            Parameter.category: category.serverValue ?? "ALL"
        ])
    }

    /**
     #8 지도에서 착한가격업소 마커를 클릭했을 때 호출
     - Parameter storeId: 클릭된 업소 ID
     */
    func logClickGoodPriceStore(storeId: Int) {
        AnalyticsService.logEvent(Event.clickGoodPriceStore, parameters: [
            Parameter.goodPriceStoreId: storeId
        ])
    }

    // MARK: - Helpers

    /// college/major가 nil이면 해당 키를 제외하고 파라미터 dict 구성
    private func makeParameters(
        collegeId: Int?,
        majorId: Int?,
        extra: [String: Any] = [:]
    ) -> [String: Any] {
        var parameters: [String: Any] = extra
        if let collegeId = collegeId {
            parameters[Parameter.college] = collegeId
        }
        if let majorId = majorId {
            parameters[Parameter.major] = majorId
        }
        return parameters
    }
}
