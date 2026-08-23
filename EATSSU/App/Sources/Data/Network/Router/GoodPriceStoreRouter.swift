//
//  GoodPriceStoreRouter.swift
//  EATSSU
//
//  Created by 황상환 on 8/23/26.
//

import Foundation

import Moya

enum GoodPriceStoreRouter {
    /// 전체 목록 조회 (업종 필터는 클라이언트에서 처리)
    case getStores
    /// 상세 조회
    case getStoreDetail(id: Int)
}

extension GoodPriceStoreRouter: TargetType {
    var baseURL: URL {
        URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .getStores:
            return "/good-price-stores"
        case .getStoreDetail(let id):
            return "/good-price-stores/\(id)"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        return .requestPlain
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
