//
//  TokenManager.swift
//  EATSSU
//
//  Created by 황상환 on 7/25/25.
//

import Foundation

struct TokenPayload: Decodable {
    let exp: TimeInterval
}

final class TokenManager {
    static let shared = TokenManager()
    private init() {}

    /// 토큰 남은 시간이 [2시간] 이하이면 재발급 시도
    private let expireThreshold: TimeInterval = 60 * 60 * 2
    
    /// accessToken 디코딩하여 만료 여부 판단
    func isTokenExpiringSoon() -> Bool {
        let token = RealmService.shared.getToken()
        guard let payload = decodePayload(token: token) else {
            return true // 디코딩 실패 시 만료로 간주
        }

        let expirationDate = Date(timeIntervalSince1970: payload.exp)
        return Date() >= expirationDate.addingTimeInterval(-expireThreshold)
    }

    /// 재발급이 필요하면 TokenRefresher로 실행
    func refreshIfNeeded() async {
        if isTokenExpiringSoon() {
            do {
                try await TokenRefresher.shared.refreshIfNeeded()
            } catch {
                print("앱 시작/포그라운드 시 재발급 실패: \(error)")
            }
        }
    }

    /// JWT Payload 디코딩
    private func decodePayload(token: String) -> TokenPayload? {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else { return nil }

        var base64 = parts[1]
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 {
            base64 += "="
        }

        guard let data = Data(base64Encoded: base64) else { return nil }
        return try? JSONDecoder().decode(TokenPayload.self, from: data)
    }
}

extension TokenManager {
    static func refreshIfNeededAsync() {
        Task {
            await TokenManager.shared.refreshIfNeeded()
        }
    }
}
