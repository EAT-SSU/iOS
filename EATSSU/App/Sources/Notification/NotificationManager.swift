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
