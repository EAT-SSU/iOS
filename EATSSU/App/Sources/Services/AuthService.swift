//
//  AuthService.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 8/5/25.

import Foundation

import RxSwift
import RxRelay

/// 인증 상태 및 토큰 관리 서비스
final class AuthService {
    static let shared = AuthService()
    private let disposeBag = DisposeBag()
    private let relay = BehaviorRelay<Bool>(value: false)
    private let logoutMessageRelay = BehaviorRelay<String?>(value: nil)

    var isAuthenticated: Observable<Bool> {
      relay.asObservable()
    }

    private init() {
        let hasToken = isTokenValid()
        relay.accept(hasToken)
    }

    func login(accessToken: String, refreshToken: String) {
        print("[AuthService] login() 호출됨")
        RealmService.shared.addToken(accessToken: accessToken, refreshToken: refreshToken)
        relay.accept(true)
    }

    func logout(message: String? = nil) {
        print("[AuthService] logout() 호출됨")
        RealmService.shared.deleteAll(Token.self)
        if let message = message {
            logoutMessageRelay.accept(message)
        }
        relay.accept(false)
    }
    
    var logoutMessage: Observable<String?> {
        logoutMessageRelay.asObservable()
    }

    func isTokenValid() -> Bool {
        let token = RealmService.shared.getToken()
        guard let payload = TokenManager.shared.decodePayload(token: token) else {
            logout()
            print("[AuthService] 디코딩 실패")
            return false
        }
        print("[AuthService] exp: \(payload.exp), now: \(Date().timeIntervalSince1970)")
        return Date(timeIntervalSince1970: payload.exp) > Date()
    }

    func checkAndRefreshTokenIfNeeded() async -> Bool {
        print("[AuthService] checkAndRefreshTokenIfNeeded() 시작")

        let token = RealmService.shared.getToken()
        guard let payload = TokenManager.shared.decodePayload(token: token) else {
            logout()
            print("[AuthService] 디코딩 실패")
            return false
        }
        print("[AuthService] exp: \(payload.exp), now: \(Date().timeIntervalSince1970)")

        // 만료됐어도 isTokenExpiringSoon()이 true이므로 재발급 시도
        if TokenManager.shared.isTokenExpiringSoon() {
            do {
                try await TokenRefresher.shared.refreshIfNeeded()
                print("[AuthService] 토큰 재발급 성공")
            } catch {
                logout(message: "세션이 만료되었습니다. 다시 로그인해주세요.")
                print("[AuthService] 토큰 재발급 실패")
                return false
            }
        }

        // 재발급 성공 또는 아직 유효하다면 로그인 상태로 전환
        relay.accept(true)
        return true
    }
}
