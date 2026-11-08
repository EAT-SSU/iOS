//
//  NotificationPermissionPrompt.swift
//  EATSSU
//
//  Created by 황상환 on 11/8/26.
//

import UIKit
import UserNotifications

/// 알림 허용 안내 다이얼로그
///
/// - 가입(로그인) 직후: "잇슈의 유용한 소식을 받아보세요" → 나중에 / 알림 허용하기
/// - 기기 알림 권한이 꺼져 있을 때: "알림 권한이 꺼져 있어요" → 취소 / 설정으로 이동
///
/// 서버 로그인 응답에 신규 가입 여부가 없어, "로그인 직후 + 기기 권한을 아직 묻지 않음(notDetermined)"을 가입 직후로 본다.
/// 권한을 이미 답한 기기에서는 다시 묻지 않고, 마이페이지 토글로 바꿀 수 있다
enum NotificationPermissionPrompt {

    /// 로그인·가입이 끝나 탭바로 넘어갈 때 켠다. 탭바가 나타나면 한 번 확인하고 끈다
    static var isPendingAfterLogin = false

    /// 탭바가 나타났을 때 호출. 로그인 직후이고 기기 권한이 미결정이면 안내 다이얼로그를 띄운다
    static func presentWelcomeIfNeeded(on tabBar: CustomTabBarContainerController) {
        guard isPendingAfterLogin else { return }
        isPendingAfterLogin = false
        Task { @MainActor in
            let settings = await NotificationManager.shared.checkNotificationSetting()
            guard settings.authorizationStatus == .notDetermined else { return }
            tabBar.showDialog(
                title: TextLiteral.Notification.welcomeTitle,
                message: TextLiteral.Notification.welcomeMessage,
                cancelButtonTitle: TextLiteral.Notification.later,
                confirmButtonTitle: TextLiteral.Notification.allow,
                cancelAction: nil,
                confirmAction: { requestPermission(on: tabBar) }
            )
        }
    }

    /// "알림 허용하기": 미결정이면 시스템 권한 요청, 이미 거부돼 있으면 설정 이동 안내
    /// 허용되면 마이페이지 토글을 켜고 서버에 푸시 토큰을 등록한다
    static func requestPermission(on tabBar: CustomTabBarContainerController) {
        Task { @MainActor in
            let settings = await NotificationManager.shared.checkNotificationSetting()
            switch settings.authorizationStatus {
            case .notDetermined:
                let granted = (try? await NotificationManager.shared.requestNotificationPermission()) ?? false
                UserDefaults.standard.set(granted, forKey: TextLiteral.MyPage.pushNotificationUserSettingKey)
                PushTokenManager.shared.sync()
            case .denied:
                presentSettingsDialog(on: tabBar)
            default:
                UserDefaults.standard.set(true, forKey: TextLiteral.MyPage.pushNotificationUserSettingKey)
                PushTokenManager.shared.sync()
            }
        }
    }

    /// 기기 알림 권한이 꺼져 있을 때: 설정 앱으로 안내
    static func presentSettingsDialog(on tabBar: CustomTabBarContainerController) {
        tabBar.showDialog(
            title: TextLiteral.Notification.settingsTitle,
            message: TextLiteral.Notification.settingsMessage,
            cancelButtonTitle: TextLiteral.Common.cancel,
            confirmButtonTitle: TextLiteral.Common.moveToSetting,
            cancelAction: nil,
            confirmAction: { NotificationManager.shared.openNotificationSettings() }
        )
    }
}
