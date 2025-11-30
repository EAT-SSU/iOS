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
                    // 🔥 Raw JSON 출력 (디버깅용)
                    print("------ Raw JSON ------")
                    if let raw = String(data: response.data, encoding: .utf8) {
                        print(raw)
                    } else {
                        print("❌ Raw JSON 출력 실패: 인코딩 불가")
                    }
                    print("-----------------------")
                    let baseResponse = try response.map(BaseResponse<R>.self)
                    
                    if baseResponse.isSuccess {
                        if let data = baseResponse.result {
                            completion(.success(data))
                        } else {
                            if R.self == Bool.self {
                                guard let successValue = true as? R else {
                                    completion(.failure(NetworkError.decodingError(NSError(domain: "NetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Bool 타입 변환에 실패했습니다."]))))
                                    return
                                }
                                completion(.success(successValue))
                            } else {
                                completion(.failure(NetworkError.noData(code: baseResponse.code)))
                            }
                        }
                    } else {
                        completion(.failure(NetworkError.serverError(code: baseResponse.code, message: baseResponse.message)))
                    }
                } catch {
                    completion(.failure(NetworkError.decodingError(error)))
                }
                
            case .failure(let error):
                completion(.failure(NetworkError.underlying(error)))
            }
        }
    }
}
