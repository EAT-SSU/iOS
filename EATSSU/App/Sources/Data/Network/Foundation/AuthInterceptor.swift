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
        
        if let urlString = urlRequest.url?.absoluteString, urlRequest.requiresToken {
            urlRequest.headers.add(name: "Authorization",
                                   value: "Bearer \(RealmService.shared.getToken())")
        }
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request,
               for session: Session,
               dueTo error: any Error,
               completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        reissueProvider.request(.reissuance) { [weak self] response in
            switch response {
            case let .success(moyaResponse):
                do {
                    let responseData = try moyaResponse.map(BaseResponse<SignResponse>.self)
                    guard let data = responseData.result else {
                        return
                    }
                    RealmService.shared.addToken(accessToken: data.accessToken,
                                                 refreshToken: data.refreshToken)
                    completion(.retry)
                } catch let error {
                    completion(.doNotRetryWithError(error))
                }
                
            case .failure(let error):
                completion(.doNotRetryWithError(error))
            }
        }
    }
}
