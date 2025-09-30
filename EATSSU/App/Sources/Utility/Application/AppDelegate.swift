//
//  AppDelegate.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/02/13.
//

import AuthenticationServices
import UIKit

import Firebase
import FirebaseMessaging
import KakaoSDKCommon
import NMapsMap
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    // MARK: - UIApplicationDelegate Methods

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureRealm()
        setupNotificationPermissions()
        startNetworkMonitoring()
        configureFirebase()
        setupFCM(application)
        handleAppleSignIn()
        initializeKakaoSDK()
        setupDebugConfigurations()
        configureNaverMapAuth()
        TokenManager.refreshIfNeededAsync()
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
        let notification = response.notification
        let userInfo = notification.request.content.userInfo
        
        // FCM 알림인지 확인
        if isFCMNotification(userInfo) {
            LaunchSourceManager.shared.setSource(.remoteNotification)
        } else {
            LaunchSourceManager.shared.setSource(.localNotification)
        }
        
        completionHandler()
    }
    
    // FCM: APNS 토큰 등록 성공
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNS token: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // FCM: APNS 토큰 등록 실패
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    // 네이버 맵 키 설정
    private func configureNaverMapAuth() {
        if let key = Bundle.main.infoDictionary?["NAVER_CLIENT_ID"] as? String {
            NMFAuthManager.shared().ncpKeyId = key
            print("NaverMap Client ID 설정 완료: \(key)")
        } else {
            print("NAVER_CLIENT_ID 못 찾음")
        }
    }

    // MARK: - Private Methods
    
    /// FCM 알림인지 확인하는 메서드
    private func isFCMNotification(_ userInfo: [AnyHashable: Any]) -> Bool {
        // FCM 알림의 특징적인 키들을 확인
        return userInfo["gcm.message_id"] != nil ||
               userInfo["google.c.a.e"] != nil ||
               userInfo["fcm_options"] != nil
    }

    private func configureRealm() {
        let config = Realm.Configuration(
            // 데이터베이스의 버전을 설정 - 구조를 변경할 때마다 이 숫자를 1씩 증가
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    // UserInfo에 새 속성들이 추가된 경우, Realm이 자동으로 처리
                }
            }
        )
        Realm.Configuration.defaultConfiguration = config
    }
    
    /// 푸시 알림 권한을 요청하고 설정을 처리합니다.
    private func setupNotificationPermissions() {
        _Concurrency.Task {
            do {
                let granted = try await NotificationManager.shared.requestNotificationPermission()
                
                let userSettingKey = TextLiteral.MyPage.pushNotificationUserSettingKey
                
                let hasExistingSetting = UserDefaults.standard.object(forKey: userSettingKey) != nil
                let isAppPermissionGranted = UserDefaults.standard.bool(forKey: userSettingKey)

                if granted {
                    if !hasExistingSetting || isAppPermissionGranted {
                        NotificationManager.shared.scheduleWeekday11AMNotification()
                        UserDefaults.standard.set(true, forKey: userSettingKey)
                    } else {
                        NotificationManager.shared.cancelWeekday11AMNotification()
                    }
                } else {
                    NotificationManager.shared.cancelWeekday11AMNotification()
                    UserDefaults.standard.set(false, forKey: userSettingKey)
                }
            } catch {
                // 권한 요청 실패 시 처리
                print("알림 권한 요청 실패: \(error)")
                NotificationManager.shared.cancelWeekday11AMNotification()
                UserDefaults.standard.set(false, forKey: TextLiteral.MyPage.pushNotificationUserSettingKey)
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
        
        #if DEBUG
            // 개발 환경에서는 Analytics 비활성화
            Analytics.setAnalyticsCollectionEnabled(false)
            print("Firebase Analytics: 개발 환경에서 비활성화됨")
        #else
            // 릴리즈 환경에서는 Analytics 활성화
            Analytics.setAnalyticsCollectionEnabled(true)
            print("Firebase Analytics: 릴리즈 환경에서 활성화됨")
        #endif
    }
    
    /// FCM(Firebase Cloud Messaging)을 설정합니다.
    private func setupFCM(_ application: UIApplication) {
        // FCM 메시징 델리게이트 설정
        Messaging.messaging().delegate = self
        
        // 원격 알림 등록
        application.registerForRemoteNotifications()
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
            newArguments.append("-FIRAnalyticsDebugEnabled")
            ProcessInfo.processInfo.setValue(newArguments, forKey: "arguments")
        #endif

        // 앱 실행을 잠시 지연시킵니다. (필요한 경우)
        sleep(1)
    }
}

// MARK: - UNUserNotificationCenterDelegate Extension
extension AppDelegate {
    // Foreground에서도 알림이 보이도록 설정
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}

// MARK: - MessagingDelegate Extension
extension AppDelegate: MessagingDelegate {
    // FCM 토큰이 갱신될 때 호출
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        
        // TODO: 필요시 서버에 토큰 전송
        // 앱 시작시와 토큰이 새로 생성될 때마다 호출됩니다.
    }
}
