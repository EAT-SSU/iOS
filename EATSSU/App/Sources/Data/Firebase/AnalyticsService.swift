//
//  AnalyticsService.swift
//  EATSSU
//
//  Created on 2026/03/04.
//

import FirebaseAnalytics
import PostHog

enum AnalyticsService {
    /// 커스텀 이벤트 로깅 (Firebase + PostHog)
    static func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
        #if !DEBUG
        PostHogSDK.shared.capture(name, properties: parameters)
        #endif
    }

    /// 화면 조회 로깅 (Firebase + PostHog)
    static func logScreen(_ name: String, screenClass: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: name,
            AnalyticsParameterScreenClass: screenClass
        ])
        #if !DEBUG
        PostHogSDK.shared.screen(name, properties: [
            "screen_class": screenClass
        ])
        #endif
    }
}
