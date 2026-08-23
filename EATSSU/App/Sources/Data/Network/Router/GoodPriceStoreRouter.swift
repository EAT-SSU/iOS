//
//  GoodPriceStoreRouter.swift
//  EATSSU
//
//  Created by 황상환 on 8/23/26.
//

import Foundation

import Moya

enum GoodPriceStoreRouter {
    /// 목록 조회. category가 nil이면 전체
    case getStores(category: GoodPriceCategory?)
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
        switch self {
        case .getStores(let category):
            guard let category, let serverValue = category.serverValue else {
                return .requestPlain
            }
            return .requestParameters(
                parameters: ["category": serverValue],
                encoding: URLEncoding.queryString
            )
        case .getStoreDetail:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
