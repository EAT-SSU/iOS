//
//  AuthInterceptor.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 11/13/23.
//

import Foundation

import Alamofire
import Moya

/// 네트워크 요청에 accessToken을 자동 부착하고,
/// 인증 실패 시 refreshToken으로 자동 재발급을 시도하는 인터셉터
final class AuthInterceptor: RequestInterceptor {
    
    static let shared = AuthInterceptor()
    
    /// accessToken이 만료되었을 때 재시도할 상태코드 목록
    /// 서버는 토큰 만료·무효에 401, 권한 부족(남의 리뷰 수정 등)에 403을 준다
    private let refreshStatusCodes: Set<Int> = [401]
    
    /// 모든 요청에 accessToken을 부착 (단, 재발급 요청은 예외)
    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        
        // 토큰 재발급 요청 자체에는 토큰을 붙이지 않음
        if request.url?.path == ReissueRouter.reissuance.path {
            return completion(.success(request))
        }
        
        // 토큰이 필요한 요청에만 Authorization 헤더 추가
        if request.requiresToken {
            request.headers.add(
                name: "Authorization",
                value: "Bearer \(RealmService.shared.getToken())"
            )
        }
        
        completion(.success(request))
    }
    
    /// 인증 실패(401) 발생 시 refreshToken으로 accessToken 재발급 시도
    /// 성공하면 동일 요청을 한 번만 재시도, 실패하면 그대로 실패 처리
    func retry(_ request: Request,
               for session: Session,
               dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {

        // 응답 코드가 401인 경우만 재발급 시도
        guard let statusCode = (request.task?.response as? HTTPURLResponse)?.statusCode,
              refreshStatusCodes.contains(statusCode) else {
            return completion(.doNotRetryWithError(error))
        }

        // 재발급 후 재시도한 요청이 또 실패하면 반복하지 않음
        guard request.retryCount == 0 else {
            return completion(.doNotRetryWithError(error))
        }

        // 비로그인 상태면 재발급할 토큰이 없음
        guard !RealmService.shared.getRefreshToken().isEmpty else {
            return completion(.doNotRetryWithError(error))
        }
        
        print("retry 호출 – statusCode: \(statusCode)")
        
        // Swift Concurrency 기반 비동기 재발급 처리
        _Concurrency.Task { 
            do {
              try await TokenRefresher.shared.refreshIfNeeded()
              await MainActor.run { completion(.retry) }
            } catch {
              if case TokenRefresherError.sessionExpired = error {
                  TokenRefresher.sessionExpiredPublisher.send()
              }
              await MainActor.run { completion(.doNotRetryWithError(error)) }
            }
          }
    }
}
