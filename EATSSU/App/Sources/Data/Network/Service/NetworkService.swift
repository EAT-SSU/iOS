//
//  NetworkService.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 10/17/25.
//

import Foundation

import Moya
import Alamofire

final class NetworkService {
    
    // MARK: - Singleton
    
    static let shared = NetworkService()
    
    private init() {}
    
    // MARK: - Providers
        
    /// 기본 Provider (로깅만)
    private func defaultProvider<T: TargetType>() -> MoyaProvider<T> {
        return MoyaProvider<T>(plugins: [ESMoyaLoggingPlugin()])
    }
    
    /// 인증 Provider (AuthInterceptor + 로깅)
    private func authProvider<T: TargetType>() -> MoyaProvider<T> {
        return MoyaProvider<T>(
            session: Session(interceptor: AuthInterceptor.shared),
            plugins: [ESMoyaLoggingPlugin()]
        )
    }
    
    // MARK: - Request Method
    
    /// Generic 네트워크 요청 메서드
    func request<T: TargetType, R: Codable>(
        _ target: T,
        responseType: R.Type,
        useAuth: Bool = false,
        completion: @escaping (Result<R, Error>) -> Void
    ) {
        let provider: MoyaProvider<T> = useAuth ? authProvider() : defaultProvider()
        
        provider.request(target) { result in
            switch result {
            case .success(let response):
                do {
                    let baseResponse = try response.map(BaseResponse<R>.self)
                    
                    if baseResponse.isSuccess {
                        if let data = baseResponse.result {
                            completion(.success(data))
                        } else {
                            if R.self == Bool.self {
                                completion(.success(true as! R))
                            } else {
                                let error = NSError(
                                    domain: "NetworkService",
                                    code: baseResponse.code,
                                    userInfo: [NSLocalizedDescriptionKey: "응답 데이터가 없습니다."]
                                )
                                completion(.failure(error))
                            }
                        }
                    } else {
                        let error = NSError(
                            domain: "NetworkService",
                            code: baseResponse.code,
                            userInfo: [NSLocalizedDescriptionKey: baseResponse.message]
                        )
                        completion(.failure(error))
                    }
                } catch {
                    completion(.failure(error))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
