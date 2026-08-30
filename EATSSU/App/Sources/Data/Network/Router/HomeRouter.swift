//
//  HomeRouter.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/05/27.
//

import Foundation
import Moya

enum HomeRouter {
    /// 변동식단 조회. `language`를 주면 대표메뉴(isMain) 이름이 해당 언어로 내려온다 (현재 서버는 EN만 지원, nil이면 한국어)
    case getChangeMenuTableResponse(date: String, restaurant: String, time: String, language: String? = nil)
    /// 특정 식사(mealId)의 메뉴 목록 조회. 응답 구조는 `/meals` 항목과 동일하며 `language` 동작도 같다
    case getMealMenusInfo(mealId: Int, language: String? = nil)
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
        case let .getMealMenusInfo(mealId, _):
            "/meals/\(mealId)/menus-info"
        case .getFixedMenuTableResponse:
            "/menus"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getChangeMenuTableResponse,
             .getMealMenusInfo,
             .getFixedMenuTableResponse:
            .get
        }
    }

    var task: Task {
        switch self {
        case let .getChangeMenuTableResponse(date, restaurant, time, language):
            // language가 nil이면 키 자체가 빠져 기존 요청과 동일해진다
            var parameters: [String: Any] = ["date": date, "restaurant": restaurant, "time": time]
            parameters["language"] = language
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .getMealMenusInfo(_, language):
            var parameters: [String: Any] = [:]
            parameters["language"] = language
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .getFixedMenuTableResponse(restaurant):
            return .requestParameters(parameters: ["restaurant": restaurant],
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
