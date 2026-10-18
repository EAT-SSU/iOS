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

    /// 요청 중인지. 등록·삭제 요청을 한 번에 하나만 보내 서버에 도착하는 순서가 뒤바뀌지 않게 한다
    private var isSyncing = false

    /// 요청 중에 다시 맞춰야 할 일이 생겼는지 (예: 토글을 빠르게 껐다 켬). 응답 후 한 번 더 맞춘다
    private var needsResync = false

    /// 로그아웃 처리 중. 로그아웃 삭제 요청 뒤에 등록 요청이 다시 나가지 않게 막는다
    private var isLoggingOut = false

    /// 진행 중인 요청이 끝나면 실행할 작업 (로그아웃 삭제 요청을 진행 중인 등록 요청 뒤로 보낸다)
    private var onSyncFinished: (() -> Void)?

    /// `reset()`마다 증가. 초기화 전에 보낸 요청의 응답이 다음 계정의 상태를 바꾸지 않게 한다
    private var sessionVersion = 0

    /// 로그아웃·탈퇴·세션 만료 시 호출. 다음 로그인 계정에 다시 등록되게 한다
    func reset() {
        sessionVersion += 1
        lastSynced = nil
        isSyncing = false
        needsResync = false
        isLoggingOut = false
        onSyncFinished = nil
    }

    // MARK: - Sync

    /// 현재 상태에 맞게 서버에 토큰을 등록하거나 삭제한다
    /// 호출 시점: 로그인 상태로 진입, FCM 토큰 갱신, 알림 권한 결과, 마이페이지 알림 토글 변경
    func sync() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { self.sync() }
            return
        }
        guard !isLoggingOut,
              TokenStore.hasAccessToken,
              let token = Messaging.messaging().fcmToken, !token.isEmpty else { return }
        // 이전 요청의 응답 전에 바뀐 상태는 응답 후 반영한다. 응답 전에 비교하면 아직 반영되지 않은 상태와 비교하게 된다
        guard !isSyncing else {
            needsResync = true
            return
        }
        isSyncing = true
        let session = sessionVersion

        Task { @MainActor in
            let shouldRegister = await Self.isNotificationEnabled()
            // 확인하는 사이 계정이 초기화됐으면 이 요청은 이전 계정의 것이므로 버린다
            guard session == sessionVersion else { return }
            // 로그아웃이 시작됐거나 이미 같은 상태면 보내지 않는다
            let isAlreadySynced = lastSynced.map { $0.token == token && $0.isRegistered == shouldRegister } ?? false
            guard !isLoggingOut, TokenStore.hasAccessToken, !isAlreadySynced else {
                finishSync()
                return
            }

            let target: PushTokenRouter = shouldRegister ? .register(token: token) : .unregister(token: token)
            // 앱 수명 동안 유지되는 싱글턴이라 self를 그대로 캡처한다
            NetworkService.shared.request(target, responseType: Bool.self, useAuth: true) { result in
                guard session == self.sessionVersion else { return }
                switch result {
                case .success:
                    self.lastSynced = (token, shouldRegister)
                case .failure(let error):
                    // 다음 진입·토큰 갱신 때 다시 맞추므로 사용자에게 알리지 않는다
                    print("푸시 토큰 \(shouldRegister ? "등록" : "삭제") 실패: \(error.localizedDescription)")
                }
                self.finishSync()
            }
        }
    }

    private func finishSync() {
        isSyncing = false
        if let onSyncFinished {
            self.onSyncFinished = nil
            onSyncFinished()
            return
        }
        guard needsResync else { return }
        needsResync = false
        sync()
    }

    /// 로그아웃 직전 호출. 계정 토큰이 지워지기 전에 서버의 푸시 토큰을 삭제하고 completion을 부른다.
    /// 서버에 로그아웃 API가 없어, 이 요청이 없으면 로그아웃한 기기로 이전 계정의 알림이 계속 간다.
    ///
    /// - 진행 중인 등록 요청이 있으면 그 응답 뒤에 삭제를 보내, 서버에 등록이 삭제보다 늦게 도착하지 않게 한다
    /// - 실패하거나 응답이 늦어도 `unregisterTimeout` 뒤에는 로그아웃을 진행한다
    func unregisterBeforeLogout(completion: @escaping () -> Void) {
        guard TokenStore.hasAccessToken, let token = Messaging.messaging().fcmToken, !token.isEmpty else {
            completion()
            return
        }
        isLoggingOut = true
        needsResync = false

        var didComplete = false
        let finish = {
            guard !didComplete else { return }
            didComplete = true
            completion()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.unregisterTimeout, execute: finish)

        let unregister = {
            NetworkService.shared.request(PushTokenRouter.unregister(token: token), responseType: Bool.self, useAuth: true) { result in
                if case .failure(let error) = result {
                    print("로그아웃 푸시 토큰 삭제 실패: \(error.localizedDescription)")
                }
                finish()
            }
        }
        if isSyncing {
            onSyncFinished = unregister
        } else {
            unregister()
        }
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
