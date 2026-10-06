//
//  MyRouter.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/08/07.
//

import UIKit

import Moya

enum MyRouter {
    case getMyReviewList(lastReviewId: Int?,
                             page: Int? = 0,
                             size: Int? = 20,
                             sort: String? = "date,DESC")
    case myInfo
    case signOut
    case inquiry(param: InquiryRequest)
    case getDepartment
    case getMyPartnerships
    /// 유저가 찜한 제휴 조회
    case getLikedPartnerships
    case colleges
    case departments(collegeId: Int)
    /// 유저 언어 설정 변경. 메뉴 찜 검색·목록의 메뉴명 번역 기준 (KO/EN/JA/VI)
    case updateLanguage(language: String)
}

extension MyRouter: TargetType {
    var baseURL: URL {
        URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .getMyReviewList:
            "users/v2/reviews"
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
        case .getLikedPartnerships:
            "/users/partnerships"
        case .colleges:
            "/users/lookup/colleges"
        case .departments:
            "/users/lookup/departments"
        case .updateLanguage:
            "/users/language"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getMyReviewList, .departments, .colleges:
            .get
        case .myInfo, .getDepartment, .getMyPartnerships, .getLikedPartnerships:
            .get
        case .signOut:
            .delete
        case .inquiry:
            .post
        case .updateLanguage:
            .patch
        }
    }

    var task: Moya.Task {
        switch self {
        case let .getMyReviewList(lastReviewId, page, size, sort):
                .requestParameters(
                    parameters: {
                        var dict: [String: Any] = [:]

                        if let lastId = lastReviewId {
                            dict["lastReviewId"] = lastId
                        } else {
                            dict["page"] = page ?? 0
                        }

                        dict["size"] = size ?? 20
                        dict["sort"] = sort ?? "date,DESC"
                        return dict
                    }(),
                    encoding: URLEncoding.queryString
                )
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
        case .getLikedPartnerships:
                .requestPlain
        case .colleges:
                .requestPlain
        case let .departments(collegeId):
                .requestParameters(parameters: ["collegeId": collegeId],
                                   encoding: URLEncoding.queryString)
        case let .updateLanguage(language):
                .requestParameters(parameters: ["language": language],
                                   encoding: JSONEncoding.default)
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
