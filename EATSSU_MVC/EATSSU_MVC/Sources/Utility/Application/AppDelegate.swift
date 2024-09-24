//
//  AppDelegate.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/02/13.
//

import AuthenticationServices
import UIKit

import Firebase
import KakaoSDKCommon

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// 푸시 알림 권한 요청
		NotificationManager.shared.requestNotificationPermission { granted in
			let notificationSettingValue = UserDefaults.standard.bool(forKey: TextLiteral.MyPage.pushNotificationUserSettingKey)
	
			// OS 단계에서 푸시 알림 허용 여부
			if granted {
				// OS 단계에서 푸시 알림 허용
				if notificationSettingValue {
					// 앱 단계에서 푸시 알림 값이 허용
					NotificationManager.shared.scheduleWeekday11AMNotification()
					UserDefaults.standard.set(true, forKey: TextLiteral.MyPage.pushNotificationUserSettingKey)
				} else {
					// 앱 단계에서 푸시 알림 값이 거절
					NotificationManager.shared.cancelWeekday11AMNotification()
					UserDefaults.standard.set(false, forKey: TextLiteral.MyPage.pushNotificationUserSettingKey)
				}
			} else {
				// OS 단계에서 푸시 알림 거부
				// 앱 단계에서 푸시 알림 설정 거부
				NotificationManager.shared.cancelWeekday11AMNotification()
				UserDefaults.standard.set(false, forKey: TextLiteral.MyPage.pushNotificationUserSettingKey)
			}
		}
			
		// TODO: NetworkMonitor 문서화 작성
		
		// 디버그 콘솔에서 네트워크 연결 상태 모니터링을 위한 메소드
		NetworkMonitor.shared.startMonitoring()
        
		// Firebase SDK를 사용하기 위한 처리
		FirebaseApp.configure()
        
		// Apple 사용자 인증을 위한 처리
		let appleIDProvider = ASAuthorizationAppleIDProvider()
        
		// forUserID = userIdentifier
		appleIDProvider.getCredentialState(
			forUserID: "001281.9301aaa1f617423c9c7a64b671b6eb84.0758")
		{ credentialState, _ in
			switch credentialState {
			case .authorized:
				// The Apple ID credential is valid.
				print("해당 ID는 연동되어있습니다.")
			case .revoked:
				// The Apple ID credential is either revoked or was not found, so show the sign-in UI.
				print("해당 ID는 연동되어있지않습니다.")
			case .notFound:
				// The Apple ID credential is either was not found, so show the sign-in UI.
				print("해당 ID를 찾을 수 없습니다.")
			default:
				break
			}
		}
      
		/*
		 해야 할 일
		 - "앱 실행 중 강제로 연결 취소 시" 동작하는 로직이 특별히 없는 것 같습니다.
		 - 최지우님 설명 부탁드립니다. 최지웅 작성.
		 */
      
		// 앱 실행 중 강제로 연결 취소 시
		NotificationCenter.default.addObserver(
			forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
			object: nil,
			queue: nil)
		{ _ in
			print("Revoked Notification")
		}
      
		// 카카오 SDK 사용을 위한 처리
		let kakaoAPIKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO API KEY") as! String
		KakaoSDK.initSDK(appKey: kakaoAPIKey)
      
		/*
		 해야 할 일
		 - 아래 전처리문에 대한 설명을 해주셨으면 합니다.
		 - 디버그 상황에서만 수행되는 코드인데, 왜 그런지 궁금하네요.
		 - 최지우님 설명 부탁드립니다. 최지웅 작성.
		 */
      
		#if DEBUG
		var newArguments = ProcessInfo.processInfo.arguments
		newArguments.append("-FIRDebugEnabled")
		ProcessInfo.processInfo.setValue(newArguments, forKey: "arguments")
		#endif
        
		sleep(1)
      
		return true
	}

	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}
}
