//
//  AuthenticationManager.swift
//  EATSSU
//
//  Created by 황상환 on 10/12/25.
//

import Foundation

enum AuthResult {
    case authenticated
    case notAuthenticated
    case sessionExpired
    
    var errorMessage: String? {
        if case .sessionExpired = self {
            return "세션이 만료되어 다시 로그인해주세요."
        }
        return nil
    }
}

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    private init() {}
    
    /// 저장된 토큰을 확인하고 필요시 갱신하여 인증 상태를 반환합니다.
    func checkAuthentication() async -> AuthResult {
        // 1. 토큰이 없으면 미인증 상태
        guard hasStoredToken() else {
            return .notAuthenticated
        }
        
        // 2. 토큰이 있으면 갱신 시도
        do {
            try await TokenManager.shared.refreshIfNeededWithThrow()
            return .authenticated
        } catch TokenRefresherError.sessionExpired {
            // 3. refreshToken까지 만료되면 로그아웃과 같은 기준으로 계정 상태 정리
            // AccountStorage.reset은 메인 전용 상태(찜 목록)도 비우므로 메인에서 실행
            await MainActor.run {
                AnalyticsIdentityManager.reset()
                AccountStorage.reset()
            }
            return .sessionExpired
        } catch {
            // 4. 오프라인·서버 오류는 기존 토큰으로 진입하고, 이후 401 재발급 흐름에 맡김
            return .authenticated
        }
    }
    
    private func hasStoredToken() -> Bool {
        !TokenStore.accessToken.isEmpty
    }
}
