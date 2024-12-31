//
//  HomeRouter.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/05/27.
//

import Foundation
import Moya

enum HomeRouter {
    case getChangeMenuTableResponse(date: String, restaurant: String, time: String)
    case getFixedMenuTableResponse(restaurant: String)
}

extension HomeRouter: TargetType {
    var baseURL: URL {
        return URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .getChangeMenuTableResponse:
            return "/meals"
        case .getFixedMenuTableResponse:
            return "/menus"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getChangeMenuTableResponse,
             .getFixedMenuTableResponse:
            return .get
        }
    }

    var task: Task {
        switch self {
        case let .getChangeMenuTableResponse(date, restaurant, time):
            return .requestParameters(parameters: ["date": date, "restaurant": restaurant, "time": time],
                                      encoding: URLEncoding.queryString)
        case let .getFixedMenuTableResponse(restaurant):
            return .requestParameters(parameters: ["restaurant": restaurant],
                                      encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }

    var sampleData: Data {
        return Data()
    }
}
