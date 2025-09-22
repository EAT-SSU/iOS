//
//  SceneDelegate.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/02/13.
//

import SwiftUI
import UIKit
import Intents

import KakaoSDKAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    // MARK: - UIWindowSceneDelegate Methods

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // 앱의 최초 실행 소스를 판별
        detectLaunchSource(connectionOptions: connectionOptions)
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        // 스플래시 화면 설정
        let splashVC = SplashViewController()
        window?.rootViewController = splashVC
        window?.makeKeyAndVisible()

        fetchNoticeAndConfigureRootViewController()
        checkForAppUpdate()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            // 카카오 로그인 처리
            if AuthApi.isKakaoTalkLoginUrl(url) {
                _ = AuthController.handleOpenUrl(url: url)
                return
            }
            // 위젯 실행 여부 감지
            if url.host == "from_widget" {
                LaunchSourceManager.shared.setSource(.widget)
            } else {
                LaunchSourceManager.shared.setSource(.icon)
            }
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // 백그라운드에서 포그라운드로 전환 시 필요한 작업 수행
        TokenManager.refreshIfNeededAsync()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // 앱이 완전히 포그라운드에 진입했을 때 실행 경로 로깅 처리
        handleForegroundTransition()
        checkAndNotifyNewDay()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        LaunchSourceManager.shared.appDidEnterBackground()
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        // AppIntent 기반 위젯으로 실행되었을 경우 - 실행 소스를 widget으로 설정
        if #available(iOS 17.0, *), isWidgetActivityType(userActivity.activityType) {
            LaunchSourceManager.shared.setSource(.widget)
        } else {
            LaunchSourceManager.shared.setSource(.icon)
        }
    }

    // MARK: - Launch Source Helpers

    /// 앱 실행 시 위젯 또는 알림을 통해 실행되었는지 감지하여 launch source 설정
    private func detectLaunchSource(connectionOptions: UIScene.ConnectionOptions) {
        let isFromWidget =
            wasLaunchedFromWidgetURL(connectionOptions) ||
            wasLaunchedFromWidgetActivity(connectionOptions) ||
            wasLaunchedFromWidgetDefaults()

        if isFromWidget {
            LaunchSourceManager.shared.setSource(.widget)
            return
        }

        // 알림 응답으로 인해 실행된 경우
        if let notificationResponse = connectionOptions.notificationResponse {
            let userInfo = notificationResponse.notification.request.content.userInfo
            
            // FCM 알림인지 확인
            if isFCMNotification(userInfo) {
                LaunchSourceManager.shared.setSource(.remoteNotification)
            } else {
                LaunchSourceManager.shared.setSource(.localNotification)
            }
            return
        }
        
        // 기본값은 icon
        LaunchSourceManager.shared.setSource(.icon)
    }

    /// FCM 알림인지 확인하는 메서드
    private func isFCMNotification(_ userInfo: [AnyHashable: Any]) -> Bool {
        // FCM 알림의 특징적인 키들을 확인
        return userInfo["gcm.message_id"] != nil ||
               userInfo["google.c.a.e"] != nil ||
               userInfo["fcm_options"] != nil
    }
    
    /// userActivity의 activityType이 위젯 관련 타입인지 판별
    private func isWidgetActivityType(_ activityType: String) -> Bool {
        return activityType.contains("Intent") ||
               activityType.contains("Widget") ||
               activityType.contains("IN") ||
               activityType.contains("Extension") ||
               activityType == "INStartIntent"
    }

    /// URL 기반 위젯 실행 여부 확인
    private func wasLaunchedFromWidgetURL(_ options: UIScene.ConnectionOptions) -> Bool {
        guard let url = options.urlContexts.first?.url else { return false }
        return url.absoluteString.contains("from_widget")
    }
    
    /// userActivity 기반 위젯 실행 여부 확인
    private func wasLaunchedFromWidgetActivity(_ options: UIScene.ConnectionOptions) -> Bool {
        return options.userActivities.contains { activity in
            isWidgetActivityType(activity.activityType)
        }
    }
    
    /// 앱 그룹 UserDefaults를 통해 위젯 실행 여부 확인
    private func wasLaunchedFromWidgetDefaults() -> Bool {
        let sharedDefaults = UserDefaults(suiteName: "EATSSU_WidgetGroup")
        let launchedFromWidget = sharedDefaults?.bool(forKey: "launchedFromWidget") ?? false

        if launchedFromWidget {
            let currentTime = Date().timeIntervalSince1970
            let widgetLaunchTime = sharedDefaults?.double(forKey: "widgetLaunchTime") ?? 0

            if currentTime - widgetLaunchTime < 5 {
                sharedDefaults?.set(false, forKey: "launchedFromWidget")
                sharedDefaults?.synchronize()
                return true
            }
        }

        return false
    }

    /// 앱이 포그라운드로 진입했을 때 실행 경로 확인
    private func handleForegroundTransition() {
        LaunchSourceManager.shared.logIfNeeded()
        WidgetAnalyticsManager.shared.sendPendingEvents()
    }

    // MARK: - RootViewController & Update

    private func fetchNoticeAndConfigureRootViewController() {
        FirebaseRemoteConfig.shared.noticeCheck { [weak self] result in
            DispatchQueue.main.async {
                self?.configureRootViewController(with: result)
            }
        }
    }

    private func configureRootViewController(with noticeMessage: String?) {
        let rootViewController: UIViewController = if let notice = noticeMessage, !notice.isEmpty {
            UINavigationController(rootViewController: NoticeViewController(noticeMessage: notice))
        } else {
            UINavigationController(rootViewController: LoginViewController())
        }
        window?.rootViewController = rootViewController
    }

    private func checkForAppUpdate() {
        #if DEBUG
            print("개발 환경에서는 앱 업데이트 체크를 건너뜁니다.")
            return
        #else
            DispatchQueue.global(qos: .background).async { [weak self] in
                let latestVersion = AppStoreCheck().latestVersion()
                DispatchQueue.main.async {
                    self?.handleAppUpdateCheck(latestVersion: latestVersion)
                }
            }
        #endif
    }

    private func handleAppUpdateCheck(latestVersion: String?) {
        guard let latestVersion else {
            print("앱스토어 버전을 찾지 못했습니다.")
            return
        }
        let currentVersion = AppStoreCheck.appVersion ?? ""
        let compareResult = latestVersion.compare(currentVersion, options: .numeric)
        switch compareResult {
        case .orderedAscending, .orderedSame:
            debugPrint("현재 최신 버전입니다.")
        case .orderedDescending:
            showUpdateAlert()
        }
    }

    private func showUpdateAlert() {
        let alert = UIAlertController(
            title: "업데이트 알림",
            message: "더 나은 서비스를 위해 EAT-SSU를 업데이트해주세요!",
            preferredStyle: .alert
        )

        let updateAction = UIAlertAction(title: "업데이트", style: .default) { _ in
            AppStoreCheck().openAppStore()
        }

        alert.addAction(updateAction)
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    /// 마지막 활성화 날짜와 비교해 "새로운 날"이면 알림을 보내고, 마지막 활성화 시간을 갱신
    private func checkAndNotifyNewDay() {
        let defaults = UserDefaults.standard
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        defer {
            // 마지막 활성화 날짜를 현재 시점으로 업데이트하여 다음 비교에 사용
            defaults.set(Date(), forKey: "lastActiveDate")
        }

        guard let lastActive = defaults.object(forKey: "lastActiveDate") as? Date else {
            // 저장된 날짜가 없으면 첫 실행이므로 초기 업데이트를 위해 알림을 보냄
            NotificationCenter.default.post(name: .didEnterNewDay, object: nil)
            return
        }
        
        // 저장된 날짜의 시점을 계산하여 비교 기준으로 사용
        let lastDay = calendar.startOfDay(for: lastActive)
        // 오늘이 마지막 활성화 날짜보다 이후인지 검사
        if calendar.compare(today, to: lastDay, toGranularity: .day) == .orderedDescending {
            // 새로운 날로 판단될 때, 알림을 보냄
            NotificationCenter.default.post(name: .didEnterNewDay, object: nil)
        }
    }
}
