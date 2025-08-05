//
//  AuthService.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 8/5/25.

import Foundation

import RxSwift
import RxRelay

enum AuthError: Error {
    case tokenExpired
}

/// 인증 상태 및 토큰 관리 서비스
final class AuthService {
    static let shared = AuthService()
    private let disposeBag = DisposeBag()
    private let relay = BehaviorRelay<Bool>(value: false)

    /// 인증 상태 스트림
    var isAuthenticated: Observable<Bool> {
        relay.asObservable()
    }

    private init() {
        Task {
            do {
                try await self.checkToken()
            } catch {
                self.logout()
            }
        }
    }

    /// 로그인 처리
    func login(accessToken: String, refreshToken: String) {
        RealmService.shared.addToken(
            accessToken: accessToken,
            refreshToken: refreshToken
        )
        relay.accept(true)
    }

    /// 로그아웃 처리
    func logout() {
        RealmService.shared.deleteAll(Token.self)
        relay.accept(false)
    }

    /// 토큰 유효성 검사 및 재발급
    func checkToken() async throws {
        let token = RealmService.shared.getToken()
        guard let payload = TokenManager.shared.decodePayload(token: token),
              Date(timeIntervalSince1970: payload.exp) > Date() else {
            throw AuthError.tokenExpired
        }

        try await TokenRefresher.shared.refreshIfNeeded()
        relay.accept(true)
    }
}
