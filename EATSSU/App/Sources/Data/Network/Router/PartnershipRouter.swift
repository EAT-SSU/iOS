//
//  PartnershipRouter.swift
//  EATSSU
//
//  Created by 황상환 on 7/1/25.
//

import UIKit

import Moya

enum PartnershipRouter {
    case getAllPartnerships
    /// 제휴 항목 단위 찜 토글 (등록 ↔ 취소)
    case toggleLike(partnershipId: Int)
}

extension PartnershipRouter: TargetType {
    var baseURL: URL {
        URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .getAllPartnerships:
            return "/partnerships"
        case let .toggleLike(partnershipId):
            return "/partnerships/\(partnershipId)/like"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getAllPartnerships:
            return .get
        case .toggleLike:
            return .post
        }
    }

    var task: Task {
        return .requestPlain
    }

    var headers: [String: String]? {
        switch self {
        default:
            return ["Content-Type": "application/json"]
        }
    }
}
