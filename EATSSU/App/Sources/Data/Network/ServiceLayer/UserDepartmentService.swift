//
//  UserDepartmentService.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 02/23/2025.
//

import Foundation
import Moya

/// 부서 관련 API 요청을 처리하는 서비스 클래스입니다.
///
/// 이 클래스는 사용자 부서 관련 API 요청을 수행하며, 부서 추가 기능을 제공합니다.
/// MoyaProvider를 사용하여 API 요청을 처리하며, 인증 토큰은 RealmService를 통해 가져옵니다.
final class UserDepartmentService {
    /// MoyaProvider 인스턴스
    private let provider: MoyaProvider<UserDepartmentRouter>

    /// 초기화 메서드
    ///
    /// - Parameter provider: 기본값은 `MoyaProvider<UserDepartmentRouter>()`입니다.
    init(provider: MoyaProvider<UserDepartmentRouter> = MoyaProvider<UserDepartmentRouter>()) {
        self.provider = provider
    }

    /// 부서 추가 API 요청을 수행합니다.
    ///
    /// - Parameters:
    ///   - departmentName: 추가할 부서의 이름
    ///   - completion: 요청 완료 후 호출되는 클로저.
    ///                 성공 시 서버의 응답 문자열을 반환하고, 실패 시 에러를 반환합니다.
    func addDepartment(departmentName: String, completion: @escaping (Result<String, Error>) -> Void) {
        provider.request(.addDepartment(departmentName: departmentName)) { result in
            switch result {
            case let .success(response):
                do {
                    // 서버 응답을 문자열 형태로 매핑합니다.
                    let decodedData = try JSONDecoder().decode(BaseResponseWithoutResult.self, from: response.data)
                    if decodedData.isSuccess {
                        completion(.success(decodedData.message))
                    } else {
                        // 서버에서 전달한 메시지를 포함한 에러 반환
                        let error = NSError(
                            domain: "UserDepartmentService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: decodedData.message]
                        )
                        completion(.failure(error))
                    }
                } catch {
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
