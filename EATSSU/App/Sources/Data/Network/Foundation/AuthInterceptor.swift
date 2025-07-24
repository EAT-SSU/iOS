//
//  AuthInterceptor.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 11/13/23.
//
import Foundation

import Alamofire
import Moya

final class AuthInterceptor: RequestInterceptor {
    
    static let shared = AuthInterceptor()
    private let reissueProvider = MoyaProvider<ReissueRouter>()
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        
        if urlRequest.url?.path == ReissueRouter.reissuance.path {
            return completion(.success(urlRequest))
        }
        
        if let urlString = urlRequest.url?.absoluteString,
            urlRequest.requiresToken {
             urlRequest.headers.add(
                 name: "Authorization",
                 value: "Bearer \(RealmService.shared.getToken())"
             )
         }
         completion(.success(urlRequest))
     }
    
    func retry(_ request: Request,
               for session: Session,
               dueTo error: any Error,
               completion: @escaping (RetryResult) -> Void) {
        
        if let response = request.task?.response as? HTTPURLResponse {
            print("🔁 retry 호출 – statusCode:", response.statusCode)
        } else {
            print("🔁 retry 호출 – response 없음, error:", error)
        }
        
        guard let response = request.task?.response as? HTTPURLResponse,
              (response.statusCode == 401 || response.statusCode == 403) else {
            print("🚫 재발급 미진입 – statusCode가 401/403이 아님")
            completion(.doNotRetryWithError(error))
            return
        }

        print("✅ 재발급 진입 – statusCode:", response.statusCode)
        
        reissueProvider.request(.reissuance) { [weak self] response in
            print("🔄 reissuance API 호출 시작")
            switch response {
            case let .success(moyaResponse):
                print("🔄 reissuance 성공 – rawData:", String(data: moyaResponse.data, encoding: .utf8) ?? "")

                do {
                    let responseData = try moyaResponse.map(BaseResponse<SignResponse>.self)
                    guard let data = responseData.result else {
                        return
                    }
                    RealmService.shared.addToken(accessToken: data.accessToken,
                                                 refreshToken: data.refreshToken)
                    print("🔄 재발급 완료 – 새 accessToken:", data.accessToken)
                    completion(.retry)
                } catch let error {
                    print("❌ reissuance 실패 – error:", error)
                    completion(.doNotRetryWithError(error))
                }
                
            case .failure(let error):
                completion(.doNotRetryWithError(error))
            }
        }
    }
}
