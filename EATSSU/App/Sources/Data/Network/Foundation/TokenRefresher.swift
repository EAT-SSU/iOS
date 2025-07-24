//
//  TokenRefresher.swift
//  EATSSU
//
//  Created by 황상환 on 7/24/25.
//

import Moya

actor TokenRefresher {
    static let shared = TokenRefresher()

    private var isRefreshing = false
    private var waitingContinuations: [CheckedContinuation<Void, Error>] = []

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
            RealmService.shared.addToken(accessToken: data.accessToken,
                                         refreshToken: data.refreshToken)

            waitingContinuations.forEach { $0.resume() }
            waitingContinuations.removeAll()
        } catch {
            waitingContinuations.forEach { $0.resume(throwing: error) }
            waitingContinuations.removeAll()
            throw error
        }
    }

    private func performReissuance() async throws -> SignResponse {
        try await withCheckedThrowingContinuation { continuation in
            let provider = MoyaProvider<ReissueRouter>()
            provider.request(.reissuance) { result in
                switch result {
                case .success(let response):
                    do {
                        let result = try response.map(BaseResponse<SignResponse>.self).result!
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
