//
//  AnalyticsIdentityManager.swift
//  EATSSU
//
//  Created by 황상환 on 7/4/26.
//

import FirebaseAnalytics
import PostHog

/// PostHog / Firebase 유저 식별(identify) 담당.
///
/// iOS는 로그인 시 이메일을 안정적으로 확보할 수 없어(애플 로그인은 최초 1회만 제공),
/// 이메일 대신 **기기 단위 고유 UUID**를 식별자로 사용한다.
/// 이 UUID는 Keychain에 저장되어 로그아웃/재설치 후에도 유지된다.
///
/// - 주의: 기기 단위 식별이므로 동일인의 크로스 디바이스/안드로이드 통합은 불가하다.
///   (그 수준이 필요하면 백엔드가 내려주는 고유 memberId로 교체해야 한다.)
enum AnalyticsIdentityManager {

    private enum Key {
        static let deviceUserID = "analytics_device_user_id"
    }

    private enum Property {
        static let provider = "provider"
        static let collegeId = "college_id"
        static let collegeName = "college_name"
        static let departmentId = "department_id"
        static let departmentName = "department_name"
    }

    /// 기기 단위 고유 식별자. 없으면 생성하여 Keychain에 저장한다.
    private static var deviceUserID: String {
        if let saved = KeychainHelper.read(forKey: Key.deviceUserID) {
            return saved
        }
        let newID = UUID().uuidString
        KeychainHelper.save(newID, forKey: Key.deviceUserID)
        return newID
    }

    /// 로그인 성공 또는 유저 정보 갱신 시 호출.
    /// 현재 저장된 `UserInfo`를 읽어 유저 속성으로 붙인다. (있는 값만)
    static func identify() {
        let id = deviceUserID
        var properties: [String: Any] = [:]

        if let userInfo = UserInfoManager.shared.getCurrentUserInfo() {
            // provider는 기존 login 이벤트(method)와 동일하게 소문자로 맞춘다.
            if let provider = userInfo.accountType?.rawValue.lowercased() {
                properties[Property.provider] = provider
            }
            if let collegeId = userInfo.collegeId { properties[Property.collegeId] = collegeId }
            if let collegeName = userInfo.collegeName { properties[Property.collegeName] = collegeName }
            if let departmentId = userInfo.departmentId { properties[Property.departmentId] = departmentId }
            if let departmentName = userInfo.departmentName { properties[Property.departmentName] = departmentName }
        }

        #if DEBUG
        print("👤 [Identify] id: \(id)")
        print("👤 [Identify] properties: \(properties)")
        #endif

        #if !DEBUG
        PostHogSDK.shared.identify(id, userProperties: properties.isEmpty ? nil : properties)
        #endif

        Analytics.setUserID(id)
        properties.forEach { key, value in
            Analytics.setUserProperty("\(value)", forName: key)
        }
    }

    /// 로그아웃 시 호출.
    static func reset() {
        #if !DEBUG
        PostHogSDK.shared.reset()
        #endif
        Analytics.setUserID(nil)
        // 이전 유저의 속성이 다음 유저에게 남지 않도록 함께 비운다.
        [Property.provider,
         Property.collegeId,
         Property.collegeName,
         Property.departmentId,
         Property.departmentName].forEach {
            Analytics.setUserProperty(nil, forName: $0)
        }
    }
}
