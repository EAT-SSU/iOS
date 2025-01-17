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
}

extension MyRouter: TargetType, AccessTokenAuthorizable {
    var baseURL: URL {
        return URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .myReview:
            return "/users/reviews"
        case .myInfo:
            return "/users/mypage"
        case .signOut:
            return "/users"
        case .inquiry:
            return "/inquiries/"
        }
    }

    var method: Moya.Method {
        switch self {
        case .myReview:
            return .get
        case .myInfo:
            return .get
        case .signOut:
            return .delete
        case .inquiry:
            return .post
        }
    }

    var task: Moya.Task {
        switch self {
        case .myReview:
            return .requestParameters(parameters: ["page": 0,
                                                   "size": 20,
                                                   "sort": "date,DESC"],
                                      encoding: URLEncoding.queryString)
        case .myInfo:
            return .requestPlain
        case .signOut:
            return .requestPlain
        case let .inquiry(param):
            return .requestJSONEncodable(param)
        }
    }

    var headers: [String: String]? {
        switch self {
        default:
            let token = RealmService.shared.getToken()
            return ["Content-Type": "application/json",
                    "Authorization": "Bearer \(token)"]
        }
    }

    var authorizationType: Moya.AuthorizationType? {
        switch self {
        default:
            return .bearer
        }
    }
}
