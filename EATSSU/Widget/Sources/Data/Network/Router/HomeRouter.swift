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
        URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .getChangeMenuTableResponse:
            "/meals"
        case .getFixedMenuTableResponse:
            "/menus"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getChangeMenuTableResponse,
             .getFixedMenuTableResponse:
            .get
        }
    }

    var task: Task {
        switch self {
        case let .getChangeMenuTableResponse(date, restaurant, time):
            .requestParameters(parameters: ["date": date, "restaurant": restaurant, "time": time],
                               encoding: URLEncoding.queryString)
        case let .getFixedMenuTableResponse(restaurant):
            .requestParameters(parameters: ["restaurant": restaurant],
                               encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        ["Content-type": "application/json"]
    }

    var sampleData: Data {
        Data()
    }
}
