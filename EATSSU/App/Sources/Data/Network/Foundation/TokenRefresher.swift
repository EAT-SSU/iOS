//
//  TokenRefresher.swift
//  EATSSU
//
//  Created by 황상환 on 7/24/25.
//

import Combine

import Moya

enum TokenRefresherError: Error {
    case emptyResult
    case sessionExpired
}

actor TokenRefresher {
    static let shared = TokenRefresher()

    nonisolated static let sessionExpiredPublisher = PassthroughSubject<Void, Never>()

    private var isRefreshing = false
    private var waitingContinuations: [CheckedContinuation<Void, Error>] = []
    private let provider = MoyaProvider<ReissueRouter>()

    /// accessToken이 만료되었을 경우 refreshToken으로 재발급 시도
    /// 동시에 여러 요청이 실패해도 중복 재발급 요청은 막고, 기다리게 함
    func refreshIfNeeded() async throws {
        if isRefreshing {
            return try await withCheckedThrowingContinuation { continuation in
                waitingContinuations.append(continuation)
            }
        }

        isRefreshing = true
        defer {
            isRefreshing = false
        }

        do {
            let data = try await performReissuance()
            RealmService.shared.addToken(
                accessToken: data.accessToken,
                refreshToken: data.refreshToken
            )
#if DEBUG
            print("⭐️⭐️ 재발급 완료 ⭐️⭐️ – 새 accessToken:", data.accessToken)
#endif
            // 대기 중인 모든 요청에 성공 전파
            waitingContinuations.forEach { $0.resume() }
            waitingContinuations.removeAll()
        } catch {
            // 대기 중인 모든 요청에 실패 전파
            waitingContinuations.forEach { $0.resume(throwing: error) }
            waitingContinuations.removeAll()
            throw error
        }
    }

    /// refreshToken 기반으로 accessToken 재발급 요청
    private func performReissuance() async throws -> SignResponse {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(.reissuance) { result in
                switch result {
                case .success(let response):
                    // 서버가 refreshToken도 만료된 경우
                    if response.statusCode == 403 {
                        // Publisher로 세션 만료 이벤트 발행
                        Self.sessionExpiredPublisher.send()
                        continuation.resume(throwing: TokenRefresherError.sessionExpired)
                        return
                    }

                    do {
                        let base = try response.map(BaseResponse<SignResponse>.self)
                        guard let result = base.result else {
                            continuation.resume(throwing: TokenRefresherError.emptyResult)
                            return
                        }
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }

                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
