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
final class PartnershipService {
    private let provider: MoyaProvider<PartnershipRouter>

    init(provider: MoyaProvider<PartnershipRouter> = MoyaProvider<PartnershipRouter>()) {
        self.provider = provider
    }

    /// 전체 제휴 목록 조회 API 호출
    /// - Returns: 성공 시 `[PartnershipResponse]`를 반환하는 Single, 실패 시 에러 전파
    func fetchAllPartnerships() -> Single<BaseResponse<[PartnershipResponse]>> {
        provider.rx.request(.fetchAllPartnerships)
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

    /// 특정 제휴 상세 정보 조회 API 호출
    /// - Parameter partnershipId: 조회할 제휴 ID
    /// - Returns: 성공 시 `PartnershipDetailResponse`를 반환하는 Single, 실패 시 에러 전파
    func fetchPartnershipDetail(partnershipId: Int) -> Single<BaseResponse<PartnershipDetailResponse>> {
        provider.rx.request(.fetchPartnershipDetail(partnershipId: partnershipId))
            .flatMap { response -> Single<BaseResponse<PartnershipDetailResponse>> in
                do {
                    let decoder = JSONDecoder()
                    let baseResponse = try decoder.decode(BaseResponse<PartnershipDetailResponse>.self, from: response.data)
                    return Single.just(baseResponse)
                } catch {
                    return Single.error(error)
                }
            }
    }
}
