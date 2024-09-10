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
        return URL (string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .getChangeMenuTableResponse(_, _, _):
            return "/meals"
        case .getFixedMenuTableResponse(_):
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
        case .getChangeMenuTableResponse(let date, let restaurant, let time):
            return .requestParameters(parameters: ["date": date, "restaurant": restaurant, "time": time], 
                                      encoding: URLEncoding.queryString)
        case .getFixedMenuTableResponse(let restaurant):
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
