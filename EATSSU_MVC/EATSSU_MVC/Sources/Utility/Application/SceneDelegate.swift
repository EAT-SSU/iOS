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
    
	func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		if let url = URLContexts.first?.url {
			if AuthApi.isKakaoTalkLoginUrl(url) {
				_ = AuthController.handleOpenUrl(url: url)
			}
		}
	}
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        self.checkAndUpdateIfNeeded()
    }
    
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }
        
		window = UIWindow(windowScene: windowScene)
		window?.windowScene = windowScene
        
		var navigationController = UINavigationController(rootViewController: LoginViewController())

        FirebaseRemoteConfig.shared.noticeCheck { [weak self] result in
            if result != nil {
                navigationController = 
              UINavigationController(rootViewController: NoticeViewController(noticeMessage: result ?? ""))
            } else {
            self?.window?.rootViewController = navigationController
            self?.window?.makeKeyAndVisible()
            self?.checkAndUpdateIfNeeded()
            }
        }
    }
    
	// 업데이트가 필요한지 확인 후 업데이트 알럿을 띄우는 메소드
	func checkAndUpdateIfNeeded() {
		DispatchQueue.global(qos: .background).async {
			let marketingVersion = AppStoreCheck().latestVersion()
            
			DispatchQueue.main.async {
				guard let marketingVersion = marketingVersion else {
					print("앱스토어 버전을 찾지 못했습니다.")
					return
				}
                
				// 현재 기기의 버전
				let currentProjectVersion = AppStoreCheck.appVersion ?? ""
                
				if marketingVersion != currentProjectVersion {
					self.showUpdateAlert(version: marketingVersion)
				} else {
					print("현재 최신 버전입니다.")
				}
			}
		}
	}

	// 알럿을 띄우는 메소드
	func showUpdateAlert(version: String) {
		let alert = UIAlertController(
			title: "업데이트 알림",
			message: "더 나은 서비스를 위해 EAT-SSU를 업데이트해주세요!",
			preferredStyle: .alert
		)
        
		let updateAction = UIAlertAction(title: "업데이트", style: .default) { _ in
            
			// 업데이트 버튼을 누르면 해당 앱스토어로 이동한다.
			AppStoreCheck().openAppStore()
		}
        
		alert.addAction(updateAction)
		window?.rootViewController?.present(alert, animated: true, completion: nil)
	}
}
