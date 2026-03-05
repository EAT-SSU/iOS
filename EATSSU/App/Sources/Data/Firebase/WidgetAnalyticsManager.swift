//
//  WidgetAnalyticsManager.swift
//  EATSSU
//
//  Created by 황상환 on 9/13/25.
//

import Foundation

/// 위젯에서 발생하는 이벤트를 Firebase Analytics에 로깅하는 담당자
final class WidgetAnalyticsManager {

    static let shared = WidgetAnalyticsManager()

    // MARK: - App Group UserDefaults

    /// 위젯과 메인 앱이 데이터를 공유하기 위한 공간
    let userDefaults: UserDefaults? = {
        guard let groupID = Bundle.main.infoDictionary?["AppGroupID"] as? String,
              !groupID.isEmpty else {
            assertionFailure("AppGroupID가 Info.plist에 설정되어 있지 않습니다.")
            return nil
        }
        guard let defaults = UserDefaults(suiteName: groupID) else {
            assertionFailure("UserDefaults 초기화 실패: \(groupID)")
            return nil
        }
        return defaults
    }()

    // MARK: - Event & Parameter Keys

    enum Event {
        static let addWidget = "add_widget_ios"
        static let changeWidget = "change_widget_ios"
    }

    private enum Parameter {
        static let restaurantBefore = "restaurant_before"
        static let restaurantAfter = "restaurant_after"
    }

    enum UserDefaultsKey {
        static let widgetAdded = "pendingWidgetAddedEvent"
        static let widgetChanged = "pendingWidgetChangedEvent"
    }

    /// 한글 식당명을 파라미터 형식(영어 소문자)으로 변환하기 위한 맵
    private let restaurantNameMap: [String: String] = [
        "학생식당": "haksik",
        "도담식당": "dodam",
        "기숙사 식당": "dormitory",
        "FACULTY (교직원 전용)": "faculty",
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
}
