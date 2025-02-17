//
//  PartnershipService.swift
//  EATSSUNetwork
//
//  Created by JIWOONG CHOI on 2/17/25.
//

import Foundation

import Moya
import RxMoya
import RxSwift

/// RxMoya를 사용하여 전체 제휴 목록 조회 API를 호출하고,
/// 성공 시 디코딩된 데이터의 body를 반환하며, 실패 시 에러를 전파합니다.
public final class PartnershipService {
    private let provider: MoyaProvider<PartnershipRouter>

    public init(provider: MoyaProvider<PartnershipRouter> = MoyaProvider<PartnershipRouter>()) {
        self.provider = provider
    }

    /// 전체 제휴 목록 조회 API 호출
    /// - Returns: 성공 시 `[PartnershipResponse]`를 반환하는 Single, 실패 시 에러 전파
    public func fetchAllPartnerships() -> Single<BaseResponse<[PartnershipResponse]>> {
        provider.rx.request(.fetchAllPartnerships)
            .filterSuccessfulStatusCodes() // 200~299 상태 코드만 통과
            .flatMap { response -> Single<BaseResponse<[PartnershipResponse]>> in
                do {
                    let decoder = JSONDecoder()
                    let baseResponse = try decoder.decode(BaseResponse<[PartnershipResponse]>.self, from: response.data)
                    return Single.just(baseResponse)
                } catch {
                    return Single.error(error)
                }
            }
    }
}
