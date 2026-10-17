//
//  PushTokenManager.swift
//  EATSSU
//
//  Created by 황상환 on 10/17/26.
//

import Foundation
import UserNotifications

import FirebaseMessaging

/// FCM 토큰을 서버에 등록·삭제해 알림 수신 여부를 맞춘다
///
/// 서버는 토큰이 등록돼 있으면 알림을 보낸다. 그래서 "로그인 상태 + 마이페이지 알림 ON + 기기 알림 권한 허용"일 때만
/// 등록하고, 그 외에는 삭제한다. 비로그인 사용자는 서버 API를 쓸 수 없어 알림을 받지 않는다.
final class PushTokenManager {

    // MARK: - Singleton

    static let shared = PushTokenManager()

    private init() {}

    // MARK: - Constants

    /// 로그아웃 시 삭제 요청을 기다리는 최대 시간. 네트워크가 느려도 로그아웃이 막히지 않게 한다
    private static let unregisterTimeout: TimeInterval = 3

    // MARK: - State

    /// 마지막으로 서버에 반영한 상태. 앱 실행 중 같은 요청을 반복하지 않게 한다
    private var lastSynced: (token: String, isRegistered: Bool)?

    /// 로그아웃·탈퇴·세션 만료 시 호출. 다음 로그인 계정에 다시 등록되게 한다
    func reset() {
        lastSynced = nil
    }

    // MARK: - Sync

    /// 현재 상태에 맞게 서버에 토큰을 등록하거나 삭제한다
    /// 호출 시점: 로그인 상태로 진입, FCM 토큰 갱신, 알림 권한 결과, 마이페이지 알림 토글 변경
    func sync() {
        guard TokenStore.hasAccessToken, let token = Messaging.messaging().fcmToken, !token.isEmpty else { return }

        Task { @MainActor in
            let shouldRegister = await Self.isNotificationEnabled()
            // 확인하는 사이 로그아웃됐으면 보내지 않는다
            guard TokenStore.hasAccessToken else { return }
            if let lastSynced, lastSynced.token == token, lastSynced.isRegistered == shouldRegister { return }

            let target: PushTokenRouter = shouldRegister ? .register(token: token) : .unregister(token: token)
            // 앱 수명 동안 유지되는 싱글턴이라 self를 그대로 캡처한다
            NetworkService.shared.request(target, responseType: Bool.self, useAuth: true) { result in
                switch result {
                case .success:
                    self.lastSynced = (token, shouldRegister)
                case .failure(let error):
                    // 다음 진입·토큰 갱신 때 다시 맞추므로 사용자에게 알리지 않는다
                    print("푸시 토큰 \(shouldRegister ? "등록" : "삭제") 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    /// 로그아웃 직전 호출. 계정 토큰이 지워지기 전에 서버의 푸시 토큰을 삭제하고 completion을 부른다.
    /// 서버에 로그아웃 API가 없어, 이 요청이 없으면 로그아웃한 기기로 이전 계정의 알림이 계속 간다.
    /// 실패하거나 응답이 늦어도 `unregisterTimeout` 뒤에는 로그아웃을 진행한다.
    func unregisterBeforeLogout(completion: @escaping () -> Void) {
        guard TokenStore.hasAccessToken, let token = Messaging.messaging().fcmToken, !token.isEmpty else {
            completion()
            return
        }

        var didComplete = false
        let finish = {
            guard !didComplete else { return }
            didComplete = true
            completion()
        }

        NetworkService.shared.request(PushTokenRouter.unregister(token: token), responseType: Bool.self, useAuth: true) { result in
            if case .failure(let error) = result {
                print("로그아웃 푸시 토큰 삭제 실패: \(error.localizedDescription)")
            }
            finish()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.unregisterTimeout, execute: finish)
    }

    // MARK: - Private

    /// 마이페이지 알림 토글 ON + 기기 알림 권한 허용
    private static func isNotificationEnabled() async -> Bool {
        guard UserDefaults.standard.bool(forKey: TextLiteral.MyPage.pushNotificationUserSettingKey) else { return false }
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied, .notDetermined:
            return false
        @unknown default:
            return false
        }
    }
}
