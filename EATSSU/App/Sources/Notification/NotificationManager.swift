//
//  NotificationManager.swift
//  EATSSU
//
//  Created by Jiwoong CHOI on 9/10/24.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager {
    // MARK: - Properties

    static let shared = NotificationManager()

    // MARK: - Methods

    /// 앱 실행 시 알림 발송 권한을 요청하는 팝업 호출 메소드
    func requestNotificationPermission() async throws -> Bool {
        return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
    }

    /// OS 단계에서 알림 수신 설정을 확인하는 메소드
    func checkNotificationSetting() async -> UNNotificationSettings {
        return await UNUserNotificationCenter.current().notificationSettings()
    }

    /// 알림을 보내도 되는 상태인지: 마이페이지 알림 토글 ON + 기기 알림 권한 허용
    /// 서버 푸시 토큰 등록(`PushTokenManager`)과 11시 로컬 알림(`DailyMenuNotificationScheduler`)이 같은 규칙을 쓴다
    static func isNotificationAllowed(authorization: UNAuthorizationStatus, isToggleOn: Bool) -> Bool {
        guard isToggleOn else { return false }
        switch authorization {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied, .notDetermined:
            return false
        @unknown default:
            return false
        }
    }

    /// 현재 토글·권한 상태로 `isNotificationAllowed`를 판단한다
    func isNotificationEnabled() async -> Bool {
        let isToggleOn = UserDefaults.standard.bool(forKey: TextLiteral.MyPage.pushNotificationUserSettingKey)
        guard isToggleOn else { return false }
        let settings = await checkNotificationSetting()
        return Self.isNotificationAllowed(authorization: settings.authorizationStatus, isToggleOn: isToggleOn)
    }

    /// 알림 권한 상태를 확인해 토글의 다음 상태를 반환. 서버 반영은 `PushTokenManager.sync()`가 한다
    func handleNotificationToggle(currentState: Bool) async throws -> Bool {
        let settings = await checkNotificationSetting()
        
        switch settings.authorizationStatus {
        case .denied:
            throw NotificationError.permissionDenied
            
        case .authorized, .provisional, .ephemeral:
            return !currentState

        case .notDetermined:
            let granted = try await requestNotificationPermission()
            
            if granted {
                return true
            } else {
                throw NotificationError.permissionDenied
            }
            
        @unknown default:
            throw NotificationError.unknown
        }
    }
    
    /// OS 알림 설정 화면으로 이동
    func openNotificationSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Error Types

    enum NotificationError: Error {
        case permissionDenied
        case unknown

        var message: String {
            switch self {
            case .permissionDenied:
                return TextLiteral.Notification.permissionDeniedMessage
            case .unknown:
                return TextLiteral.Notification.unknownErrorMessage
            }
        }

        var description: String {
            switch self {
            case .permissionDenied:
                return TextLiteral.Notification.permissionDeniedDescription
            case .unknown:
                return TextLiteral.Notification.unknownErrorDescription
            }
        }
    }
}
