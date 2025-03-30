//
//  SceneDelegate.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/02/13.
//

import SwiftUI
import UIKit

import KakaoSDKAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    // MARK: - UIWindowSceneDelegate Methods

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        // 스플래시
        let splashVC = SplashViewController()
        window?.rootViewController = splashVC
        window?.makeKeyAndVisible()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.fetchNoticeAndConfigureRootViewController()
            self?.checkForAppUpdate()
        }
    }

    func scene(_: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url, AuthApi.isKakaoTalkLoginUrl(url) else { return }
        _ = AuthController.handleOpenUrl(url: url)
    }

    func sceneWillEnterForeground(_: UIScene) {
        // 백그라운드에서 포그라운드로 전환 시 필요한 작업 수행
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
}
