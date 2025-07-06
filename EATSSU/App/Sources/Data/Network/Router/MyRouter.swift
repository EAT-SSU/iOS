//
//  MyRouter.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/08/07.
//

import UIKit

import Moya

enum MyRouter {
    case myReview
    case myInfo
    case signOut
    case inquiry(param: InquiryRequest)
    case getDepartment
}

extension MyRouter: TargetType {
    var baseURL: URL {
        URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .myReview:
            "/users/reviews"
        case .myInfo:
            "/users/mypage"
        case .signOut:
            "/users"
        case .inquiry:
            "/inquiries/"
        case .getDepartment:
            "/users/department"
        }
    }

    var method: Moya.Method {
        switch self {
        case .myReview:
            .get
        case .myInfo, .getDepartment:
            .get
        case .signOut:
            .delete
        case .inquiry:
            .post
        }
    }

    var task: Moya.Task {
        switch self {
        case .myReview:
            .requestParameters(parameters: ["page": 0,
                                            "size": 20,
                                            "sort": "date,DESC"],
                               encoding: URLEncoding.queryString)
        case .myInfo:
            .requestPlain
        case .signOut:
            .requestPlain
        case let .inquiry(param):
            .requestJSONEncodable(param)
        case .getDepartment:
            .requestPlain
        }
    }

    var headers: [String: String]? {
        switch self {
        default:
            return ["Content-Type": "application/json"]
        }
    }
}

extension MyRouter {
    var validationType: ValidationType {
        return .successCodes
    }
}
