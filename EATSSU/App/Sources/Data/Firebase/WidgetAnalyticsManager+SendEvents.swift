//
//  WidgetAnalyticsManager+SendEvents.swift
//  EATSSU
//
//  메인 앱 타겟에서만 포함되는 파일입니다.
//  AnalyticsService를 통해 Firebase + PostHog에 위젯 이벤트를 전송합니다.
//

extension WidgetAnalyticsManager {
    /// (메인 앱에서 호출) 기록된 위젯 이벤트가 있다면 Analytics로 전송하고 기록을 삭제합니다.
    func sendPendingEvents() {
        // 1. 위젯 추가 이벤트 전송
        if userDefaults?.bool(forKey: UserDefaultsKey.widgetAdded) == true {
            AnalyticsService.logEvent(Event.addWidget)
            userDefaults?.removeObject(forKey: UserDefaultsKey.widgetAdded)
            #if DEBUG
            print("Analytics: Logged add_widget_ios")
            #endif
        }

        // 2. 위젯 변경 이벤트 전송
        if let changeInfo = userDefaults?.dictionary(forKey: UserDefaultsKey.widgetChanged) as? [String: String] {
            AnalyticsService.logEvent(Event.changeWidget, parameters: changeInfo)
            userDefaults?.removeObject(forKey: UserDefaultsKey.widgetChanged)
            #if DEBUG
            print("Analytics: Logged change_widget_ios with params \(changeInfo)")
            #endif
        }
    }
}
