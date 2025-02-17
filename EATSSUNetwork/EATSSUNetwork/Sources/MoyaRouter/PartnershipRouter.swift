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
        // 현재 프레임워크의 번들을 가져옵니다.
        let bundle = Bundle(for: NetworkBundle.self)

        // Info.plist에서 BASE_URL 값을 읽어옵니다.
        guard let baseUrlString = bundle.infoDictionary?["BASE_URL"] as? String,
              let url = URL(string: baseUrlString)
        else {
            fatalError("Info.plist에 BASE_URL이 올바르게 설정되지 않았습니다.")
        }

        return url
    }

    /// API 경로 설정
    var path: String {
        switch self {
        case .fetchAllPartnerships:
            "/partnerships"
        case let .fetchPartnershipDetail(partnershipId):
            "/partnerships/\(partnershipId)"
        case let .togglePartnershipFavorite(partnershipId):
            "/partnerships/\(partnershipId)/like"
        }
    }

    /// HTTP 메서드 설정
    var method: Moya.Method {
        switch self {
        case .fetchAllPartnerships, .fetchPartnershipDetail:
            .get
        case .togglePartnershipFavorite:
            .post
        }
    }

    /// 요청 Task 설정
    var task: Moya.Task {
        switch self {
        case .fetchAllPartnerships, .fetchPartnershipDetail, .togglePartnershipFavorite:
            // 파라미터가 없는 경우
            .requestPlain
        }
    }

    /// HTTP 헤더 설정 (JSON 기반 요청)
    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}
