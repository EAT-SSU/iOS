//
//  AuthenticationManager.swift
//  EATSSU
//
//  Created by 황상환 on 10/12/25.
//

import Foundation
import RealmSwift

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
        } catch {
            // 3. 갱신 실패하면 토큰 삭제 후 세션 만료 처리
            RealmService.shared.deleteAll(Token.self)
            return .sessionExpired
        }
    }
    
    private func hasStoredToken() -> Bool {
        !RealmService.shared.getToken().isEmpty
    }
}
