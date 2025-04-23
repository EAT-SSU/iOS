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
    //    private var isRefreshing = false
    //    private var requestsToRetry: [(RetryResult) -> Void] = []
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        debugPrint("✅adapt 진입")
        var urlRequest = urlRequest
        
        if let urlString = urlRequest.url?.absoluteString,
           urlRequest.requiresToken {
            
            debugPrint("✅adapt reissue\(urlRequest.requiresToken)")
            debugPrint(urlString)
            debugPrint(urlRequest)
            urlRequest.headers.add(name: "Authorization", value: "Bearer \(RealmService.shared.getToken())")
            
        }
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request,
               for session: Session,
               dueTo error: any Error,
               completion: @escaping (RetryResult) -> Void) {
        debugPrint("✅retry 진입")
        
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        //        requestsToRetry.append(completion)
        //        debugPrint("🌈\(requestsToRetry)")
        
        //        if !isRefreshing {
        //            isRefreshing = true
        
        reissueProvider.request(.reissuance) { [weak self] response in
            switch response {
            case let .success(moyaResponse):
                do {
                    debugPrint("✅Token Refresh Success")
                    let responseData = try moyaResponse.map(BaseResponse<SignResponse>.self)
                    guard let data = responseData.result else {
                        debugPrint("✅Token Refresh Fail: responseData.result == nil")
                        return
                    }
                    RealmService.shared.addToken(accessToken: data.accessToken,
                                                 refreshToken: data.refreshToken)
                    //                        self?.isRefreshing = false
                    //                        self?.requestsToRetry.forEach { $0(.retry) }
                    //                        self?.requestsToRetry.removeAll()
                    completion(.retry)
                    
                } catch let error {
                    debugPrint("✅Token Refresh Fail: \(error)")
                    completion(.doNotRetryWithError(error))
                }
                
            case .failure(let error):
                debugPrint("✅Token Refresh Fail: \(error)")
                completion(.doNotRetryWithError(error))
            }
        }
    }
}
