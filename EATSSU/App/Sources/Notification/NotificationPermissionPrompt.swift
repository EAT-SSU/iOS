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
    /// 허용되면 마이페이지 토글을 켜고 수신 동의 토스트를 띄운 뒤, 서버 푸시 토큰 등록과 11시 로컬 알림 예약을 맞춘다
    /// - Parameter completion: 허용 여부. 시스템 팝업에서 거부하거나 기기 권한이 꺼져 있으면 false
    static func requestPermission(on tabBar: CustomTabBarContainerController, completion: ((Bool) -> Void)? = nil) {
        Task { @MainActor in
            let settings = await NotificationManager.shared.checkNotificationSetting()
            switch settings.authorizationStatus {
            case .notDetermined:
                let granted = (try? await NotificationManager.shared.requestNotificationPermission()) ?? false
                UserDefaults.standard.set(granted, forKey: TextLiteral.MyPage.pushNotificationUserSettingKey)
                PushTokenManager.shared.sync()
                DailyMenuNotificationScheduler.sync()
                if granted { showAgreeToast(on: tabBar) }
                completion?(granted)
            case .denied:
                presentSettingsDialog(on: tabBar)
                completion?(false)
            default:
                UserDefaults.standard.set(true, forKey: TextLiteral.MyPage.pushNotificationUserSettingKey)
                PushTokenManager.shared.sync()
                DailyMenuNotificationScheduler.sync()
                showAgreeToast(on: tabBar)
                completion?(true)
            }
        }
    }

    /// 마이페이지 토글을 켤 때와 같은 "EAT-SSU 수신 동의 (일시)" 토스트. 탭이 바뀌어도 보이도록 탭바 컨테이너에 띄운다
    private static func showAgreeToast(on tabBar: CustomTabBarContainerController) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        tabBar.showToast(message: TextLiteral.MyPage.agreeNoti(date: formatter.string(from: Date())), type: .info)
    }

    /// 찜 기능을 쓰려는데 알림이 꺼져 있을 때(마이페이지 토글 OFF 또는 권한 미결정): 허용 요청
    /// - Parameter allowed: 허용되면 바로 실행 (예: 찜 탭 카드로 이동)
    static func presentFavoriteRequest(on tabBar: CustomTabBarContainerController, allowed: @escaping () -> Void) {
        tabBar.showDialog(
            title: TextLiteral.Notification.favoriteRequestTitle,
            message: TextLiteral.Notification.favoriteRequestMessage,
            cancelButtonTitle: TextLiteral.Common.cancel,
            confirmButtonTitle: TextLiteral.Notification.allow,
            cancelAction: nil,
            confirmAction: {
                requestPermission(on: tabBar) { granted in
                    if granted { allowed() }
                }
            }
        )
    }

    /// 메뉴 찜 알림을 받을 수 있는 상태인지에 따라 안내 다이얼로그를 띄우거나 `allowed`를 실행한다
    /// - 기기 권한 거부 → 설정 이동 안내 / 토글 OFF 또는 권한 미결정 → 허용 요청 후 허용되면 allowed / 그 외 → 바로 allowed
    static func ensureFavoriteNotificationAllowed(on tabBar: CustomTabBarContainerController, allowed: @escaping () -> Void) {
        Task { @MainActor in
            let settings = await NotificationManager.shared.checkNotificationSetting()
            let isToggleOn = UserDefaults.standard.bool(forKey: TextLiteral.MyPage.pushNotificationUserSettingKey)
            switch settings.authorizationStatus {
            case .denied:
                presentSettingsDialog(on: tabBar)
            case .notDetermined:
                presentFavoriteRequest(on: tabBar, allowed: allowed)
            default:
                if isToggleOn {
                    allowed()
                } else {
                    presentFavoriteRequest(on: tabBar, allowed: allowed)
                }
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
