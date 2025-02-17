//
//  PartnershipRouter.swift
//  EATSSUNetwork
//
//  Created by JIWOONG CHOI on 2/17/25.
//

import Foundation
import Moya

/// 제휴 관련 API 요청을 정의합니다.
enum PartnershipRouter {
    /// 전체 제휴 목록을 조회합니다.
    case fetchAllPartnerships

    /// 특정 제휴의 상세 정보를 조회합니다.
    case fetchPartnershipDetail(partnershipId: Int)

    /// 제휴 찜을 등록하거나 취소합니다.
    case togglePartnershipFavorite(partnershipId: Int)
}

extension PartnershipRouter: TargetType {
    /// API 기본 URL
    var baseURL: URL {
        URL(string: AppConfiguration.baseURL)!
    }
    
    /// API 경로 설정
    var path: String {
        switch self {
        case .fetchAllPartnerships:
            return "/partnerships"
        case .fetchPartnershipDetail(let partnershipId):
            return "/partnerships/\(partnershipId)"
        case .togglePartnershipFavorite(let partnershipId):
            return "/partnerships/\(partnershipId)/like"
        }
    }
    
    /// HTTP 메서드 설정
    var method: Moya.Method {
        switch self {
        case .fetchAllPartnerships, .fetchPartnershipDetail:
            return .get
        case .togglePartnershipFavorite:
            return .post
        }
    }
    
    /// 요청 Task 설정
    var task: Moya.Task {
        switch self {
        case .fetchAllPartnerships, .fetchPartnershipDetail, .togglePartnershipFavorite:
            // 파라미터가 없는 경우
            return .requestPlain
        }
    }
    
    /// HTTP 헤더 설정 (JSON 기반 요청)
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}
