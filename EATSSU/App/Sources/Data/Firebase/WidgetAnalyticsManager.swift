//
//  WidgetAnalyticsManager.swift
//  EATSSU
//
//  Created by 황상환 on 9/13/25.
//

import Foundation
import FirebaseAnalytics

/// 위젯에서 발생하는 이벤트를 Firebase Analytics에 로깅하는 담당자
final class WidgetAnalyticsManager {
    
    static let shared = WidgetAnalyticsManager()
    
    // MARK: - App Group UserDefaults
    
    /// 위젯과 메인 앱이 데이터를 공유하기 위한 공간
    private let userDefaults = UserDefaults(suiteName: "com.jiwoo.EatSSU")

    // MARK: - Event & Parameter Keys
    
    private enum Event {
        static let addWidget = "add_widget_ios"
        static let changeWidget = "change_widget_ios"
    }
    
    private enum Parameter {
        static let restaurantBefore = "restaurant_before"
        static let restaurantAfter = "restaurant_after"
    }
    
    private enum UserDefaultsKey {
        static let widgetAdded = "pendingWidgetAddedEvent"
        static let widgetChanged = "pendingWidgetChangedEvent"
    }
    
    /// 한글 식당명을 파라미터 형식(영어 소문자)으로 변환하기 위한 맵
    private let restaurantNameMap: [String: String] = [
        "학생식당": "haksik",
        "도담식당": "dodam",
        "기숙사식당": "domitory",
        "교직원식당": "faculty"
    ]
    
    private init() {}

    // MARK: - Methods to be Called from Widget Extension

    /// (위젯에서 호출) 사용자가 위젯을 추가했을 때, 이벤트를 기록합니다.
    func recordWidgetAdded() {
        userDefaults?.set(true, forKey: UserDefaultsKey.widgetAdded)
    }
    
    /// (위젯에서 호출) 사용자가 위젯의 식당을 변경했을 때, 이전/이후 정보를 기록합니다.
    /// - Parameters:
    ///   - before: 변경 전 식당 이름 (예: "학생식당")
    ///   - after: 변경 후 식당 이름 (예: "도담식당")
    func recordWidgetChanged(before: String, after: String) {
        guard let beforeParam = restaurantNameMap[before],
              let afterParam = restaurantNameMap[after] else {
            return
        }
        
        let changeInfo = [
            Parameter.restaurantBefore: beforeParam,
            Parameter.restaurantAfter: afterParam
        ]
        
        userDefaults?.set(changeInfo, forKey: UserDefaultsKey.widgetChanged)
    }
    
    // MARK: - Method to be Called from Main App

    /// (메인 앱에서 호출) 기록된 위젯 이벤트가 있다면 Firebase로 전송하고 기록을 삭제합니다.
    func sendPendingEvents() {
        // 1. 위젯 추가 이벤트 전송
        if userDefaults?.bool(forKey: UserDefaultsKey.widgetAdded) == true {
            Analytics.logEvent(Event.addWidget, parameters: nil)
            userDefaults?.removeObject(forKey: UserDefaultsKey.widgetAdded) // 중복 전송 방지를 위해 기록 삭제
            print("Analytics: Logged add_widget_ios")
        }
        
        // 2. 위젯 변경 이벤트 전송
        if let changeInfo = userDefaults?.dictionary(forKey: UserDefaultsKey.widgetChanged) as? [String: String] {
            Analytics.logEvent(Event.changeWidget, parameters: changeInfo)
            userDefaults?.removeObject(forKey: UserDefaultsKey.widgetChanged) // 중복 전송 방지를 위해 기록 삭제
            print("Analytics: Logged change_widget_ios with params \(changeInfo)")
        }
    }
}
