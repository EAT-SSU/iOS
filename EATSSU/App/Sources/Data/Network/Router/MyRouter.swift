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
    case getMyPartnerships
    case colleges
    case departments(collegeId: Int)
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
        case .getMyPartnerships:
            "/users/department/partnerships"
        case .colleges:
            "/users/lookup/colleges"
        case .departments:
            "/users/lookup/departments"
        }
    }

    var method: Moya.Method {
        switch self {
        case .myReview, .departments, .colleges:
            .get
        case .myInfo, .getDepartment, .getMyPartnerships:
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
        case .getMyPartnerships:
                .requestPlain
        case .colleges:
                .requestPlain
        case let .departments(collegeId):
                .requestParameters(parameters: ["collegeId": collegeId],
                                   encoding: URLEncoding.queryString)
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
