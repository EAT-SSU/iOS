//
//  SceneDelegate.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/02/13.
//

import SwiftUI
import UIKit
import WidgetKit
import Intents

import KakaoSDKAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    // MARK: - UIWindowSceneDelegate Methods

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        detectLaunchSource(connectionOptions: connectionOptions)
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        // 스플래시
        let splashVC = SplashViewController()
        window?.rootViewController = splashVC
        window?.makeKeyAndVisible()

        fetchNoticeAndConfigureRootViewController()
        checkForAppUpdate()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            print("URL opened: \(url.absoluteString)")
            // 카카오 로그인
            if AuthApi.isKakaoTalkLoginUrl(url) {
                _ = AuthController.handleOpenUrl(url: url)
                return
            }
            // 위젯 체크
            if url.host == "from_widget" {
                LaunchSourceManager.shared.setSource(.widget)
            } else {
                LaunchSourceManager.shared.setSource(.icon)
            }
        }
    }

    func sceneWillEnterForeground(_: UIScene) {
        // 백그라운드에서 포그라운드로 전환 시 필요한 작업 수행
    }
    
    // 앱이 완전히 포그라운드에 들어올 때
    func sceneDidBecomeActive(_ scene: UIScene) {
        LaunchSourceManager.shared.forceBackgroundIfNeeded()
        LaunchSourceManager.shared.logIfNeeded()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        LaunchSourceManager.shared.appDidEnterBackground()
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        print("userActivity: \(userActivity.activityType)")

        if #available(iOS 17.0, *),
           userActivity.activityType.contains("Intent") ||
           userActivity.activityType.contains("Widget") ||
           userActivity.activityType.contains("IN") ||
           userActivity.activityType.contains("Extension") {

            print("App launched from Widget (via AppIntent)")
            LaunchSourceManager.shared.setSource(.widget)
        } else {
            LaunchSourceManager.shared.setSource(.icon)
        }
    }

    // MARK: - Private Methods

    private func configureWindow(with windowScene: UIWindowScene) {
        window = UIWindow(windowScene: windowScene)
        window?.windowScene = windowScene
        window?.makeKeyAndVisible()
    }

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
    
    private func detectLaunchSource(connectionOptions: UIScene.ConnectionOptions) {
        var isFromWidget = false

        // URL 확인
        if !connectionOptions.urlContexts.isEmpty,
           let url = connectionOptions.urlContexts.first?.url,
           url.absoluteString.contains("from_widget") {
            isFromWidget = true
        }

        // userActivity 확인
        if !isFromWidget && !connectionOptions.userActivities.isEmpty {
            isFromWidget = connectionOptions.userActivities.contains { activity in
                let activityType = activity.activityType
                return activityType.contains("Intent") ||
                      activityType.contains("Widget") ||
                      activityType == "INStartIntent"
            }
        }

        // UserDefaults 체크
        if !isFromWidget {
            let sharedDefaults = UserDefaults(suiteName: "EATSSU_WidgetGroup")
            let launchedFromWidget = sharedDefaults?.bool(forKey: "launchedFromWidget") ?? false

            if launchedFromWidget {
                let currentTime = Date().timeIntervalSince1970
                let widgetLaunchTime = sharedDefaults?.double(forKey: "widgetLaunchTime") ?? 0

                if currentTime - widgetLaunchTime < 5 {
                    isFromWidget = true
                    print("앱 그룹 UserDefaults로 위젯 실행 감지")
                    sharedDefaults?.set(false, forKey: "launchedFromWidget")
                    sharedDefaults?.synchronize()
                }
            }
        }

        if isFromWidget {
            print("App launched from Widget (initial connection)")
            LaunchSourceManager.shared.setSource(.widget)
        }

        if let _ = connectionOptions.notificationResponse {
            LaunchSourceManager.shared.setSource(.localNotification)
        }
    }

}
