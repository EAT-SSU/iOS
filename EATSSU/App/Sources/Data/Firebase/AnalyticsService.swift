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
        // Firebase와 이벤트명/파라미터 키를 맞추기 위해 PostHog 네이티브 .screen($screen) 대신
        // screen_view 커스텀 이벤트로 발사
        PostHogSDK.shared.capture("screen_view", properties: [
            AnalyticsParameterScreenName: name,
            AnalyticsParameterScreenClass: screenClass
        ])
        #endif
    }
}
