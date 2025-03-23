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
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    // MARK: - UIApplicationDelegate Methods

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupNotificationPermissions()
        startNetworkMonitoring()
        configureFirebase()
        handleAppleSignIn()
        initializeKakaoSDK()
        setupDebugConfigurations()
        UNUserNotificationCenter.current().delegate = self

        return true
    }

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // 새로운 scene 세션이 생성될 때 호출됩니다.
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>) {
        // 사용자가 scene 세션을 버릴 때 호출됩니다.
        // 여기서 버려진 scene과 관련된 리소스를 해제할 수 있습니다.
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        LaunchSourceManager.shared.setSource(.localNotification)
        completionHandler()
    }

    // MARK: - Private Methods

    /// 푸시 알림 권한을 요청하고 설정을 처리합니다.
    private func setupNotificationPermissions() {
        NotificationManager.shared.requestNotificationPermission { granted in
            let userSettingKey = TextLiteral.MyPage.pushNotificationUserSettingKey
            let isAppPermissionGranted = UserDefaults.standard.bool(forKey: userSettingKey)

            if granted {
                if isAppPermissionGranted {
                    NotificationManager.shared.scheduleWeekday11AMNotification()
                    UserDefaults.standard.set(true, forKey: userSettingKey)
                } else {
                    NotificationManager.shared.cancelWeekday11AMNotification()
                    UserDefaults.standard.set(false, forKey: userSettingKey)
                }
            } else {
                NotificationManager.shared.cancelWeekday11AMNotification()
                UserDefaults.standard.set(false, forKey: userSettingKey)
            }
        }
    }

    /// 네트워크 모니터링을 시작합니다.
    private func startNetworkMonitoring() {
        NetworkMonitor.shared.startMonitoring()
    }

    /// Firebase를 구성합니다.
    private func configureFirebase() {
        FirebaseApp.configure()
    }

    /// Apple ID 인증 상태를 처리합니다.
    private func handleAppleSignIn() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let userID = "001281.9301aaa1f617423c9c7a64b671b6eb84.0758"

        appleIDProvider.getCredentialState(forUserID: userID) { [weak self] credentialState, _ in
            guard self != nil else { return }
            switch credentialState {
            case .authorized:
                print("해당 ID는 연동되어있습니다.")
            case .revoked:
                print("해당 ID는 연동되어있지않습니다.")
            case .notFound:
                print("해당 ID를 찾을 수 없습니다.")
            default:
                break
            }
        }

        NotificationCenter.default.addObserver(
            forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
            object: nil,
            queue: nil
        ) { _ in
            print("Revoked Notification")
        }
    }

    /// Kakao SDK를 초기화합니다.
    private func initializeKakaoSDK() {
        guard let kakaoAPIKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO API KEY") as? String else {
            fatalError("KAKAO API KEY is missing in Info.plist")
        }
        KakaoSDK.initSDK(appKey: kakaoAPIKey)
    }

    /// 디버그 모드일 때 추가 설정을 합니다.
    private func setupDebugConfigurations() {
        #if DEBUG
            var newArguments = ProcessInfo.processInfo.arguments
            newArguments.append("-FIRDebugEnabled")
            ProcessInfo.processInfo.setValue(newArguments, forKey: "arguments")
        #endif

        // 앱 실행을 잠시 지연시킵니다. (필요한 경우)
        sleep(1)
    }
}
