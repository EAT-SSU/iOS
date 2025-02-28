//
//  UserDepartmentService.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 02/23/2025.
//

import Foundation

import Moya
import RxMoya
import RxSwift

/// 부서 관련 API 요청을 처리하는 서비스 클래스입니다.
///
/// 이 클래스는 사용자 부서 관련 API 요청을 수행하며, 부서 추가 기능을 제공합니다.
/// RxMoyaProvider를 사용하여 API 요청을 처리하며, 인증 토큰은 RealmService를 통해 가져옵니다.
final class UserDepartmentService {
    /// MoyaProvider 인스턴스
    private let provider: MoyaProvider<UserDepartmentRouter>
    private let decoder: JSONDecoder

    /// 초기화 메서드
    ///
    /// - Parameter provider: 기본값은 `MoyaProvider<UserDepartmentRouter>()`입니다.
    /// - Parameter decoder: 기본값은 `JSONDecoder()`입니다.
    init(
        provider: MoyaProvider<UserDepartmentRouter> = MoyaProvider<UserDepartmentRouter>(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.provider = provider
        self.decoder = decoder
    }

    /// 공통 디코딩 로직을 처리하는 private 메서드
    private func decode<T: Decodable>(_ type: T.Type, from response: Response) -> Single<T> {
        Single.create { single in
            do {
                let decodedData = try self.decoder.decode(type, from: response.data)
                single(.success(decodedData))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    /// 부서 추가 API 요청을 수행합니다.
    ///
    /// - Parameter departmentName: 추가할 부서의 이름
    /// - Returns: 성공 시 서버의 응답 메시지를 포함한 BaseResponseWithoutResult를 반환하는 Single
    /// - Note: 부서 추가에 실패할 경우 에러를 반환합니다.
    func addDepartment(departmentName: String) -> Single<BaseResponseWithoutResult> {
        provider.rx.request(.addDepartment(departmentName: departmentName))
            .flatMap { [weak self] response in
                guard let self else { return .error(ServiceError.instanceDeallocated) }
                return decode(BaseResponseWithoutResult.self, from: response)
            }
    }

    /// 부서 이름 검증 API 요청을 수행합니다.
    ///
    /// - Returns: 성공 시 검증 결과를 포함한 BaseResponse<Bool>을 반환하는 Single
    /// - Note: 검증에 실패할 경우 에러를 반환합니다.
    func validateDepartment() -> Single<BaseResponse<Bool>> {
        provider.rx.request(.validateDepartment)
            .flatMap { [weak self] response in
                guard let self else { return .error(ServiceError.instanceDeallocated) }
                return decode(BaseResponse<Bool>.self, from: response)
            }
    }

    /// 사용자 단과대의 제휴업체 목록을 요청합니다.
    ///
    /// - Returns: 성공 시 제휴업체 목록을 포함한 BaseResponse<[PartnershipResponse]>를 반환하는 Single
    /// - Note: 목록 조회에 실패할 경우 에러를 반환합니다.
    func getUserPartnership() -> Single<BaseResponse<[PartnershipResponse]>> {
        provider.rx.request(.getUserPartnership)
            .flatMap { [weak self] response in
                guard let self else { return .error(ServiceError.instanceDeallocated) }
                return decode(BaseResponse<[PartnershipResponse]>.self, from: response)
            }
    }
}

/// 서비스 계층에서 발생할 수 있는 에러 정의
enum ServiceError: Error {
    case instanceDeallocated
    // 필요한 다른 에러 케이스들을 추가할 수 있습니다.
}
