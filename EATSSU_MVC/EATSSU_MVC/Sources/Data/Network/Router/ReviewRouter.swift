//
//  ReviewRouter.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/05/22.
//

import Moya
import Foundation

enum ReviewRouter {
    // 상단 메뉴 별점 불러오는 API -> 두개로 쪼개짐. 고정, 변동 분기처리는 아래에서!
    case reviewRate(_ type: String, _ id: Int)
    
    // 하단 리뷰 리스트 불러오는 API
    case reviewList(_ type: String, _ id: Int)
    case report(param: ReportRequest)
    case deleteReview(_ reviewId: Int)
    case fixReview(_ reviewId: Int, _ param: BeforeSelectedImageDTO)
}

extension ReviewRouter: TargetType, AccessTokenAuthorizable {
    var baseURL: URL {
        return URL(string: Config.baseURL)!
    }
    
    var path: String {
        switch self {
        case .reviewRate(let type, let id):
            switch type {
            case "VARIABLE":
                return "/reviews/meals/\(id)"
            case "FIXED":
                return "/reviews/menus/\(id)"
            default:
                return ""
            }
        case .reviewList:
            return "/reviews"
        case .report:
            return "/reports"
        case .deleteReview(let reviewId):
            return "/reviews/\(reviewId)"
        case .fixReview(let reviewId, _):
            return "/reviews/\(reviewId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .reviewRate:
            return .get
        case .reviewList:
            return .get
        case .report:
            return .post
        case .deleteReview:
            return .delete
        case .fixReview:
            return .patch
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .reviewRate(let type, let id):
            switch type {
            case "VARIABLE":
                return .requestParameters(parameters: ["mealId": id],
                                          encoding: URLEncoding.queryString)
            case "FIXED":
                return .requestParameters(parameters: ["menuId": id],
                                          encoding: URLEncoding.queryString)
            default:
                return .requestPlain
            }
            
            /// 이후 정렬 순서, 리뷰 로드 개수 등 수정 필요하면 고치기
        case .reviewList(let type, let id):
            switch type {
            case "VARIABLE":
                return .requestParameters(parameters: ["menuType": type,
                                                       "mealId": id,
                                                       "page": 0,
                                                       "size": 20,
                                                       "sort": "date,DESC"],
                                          encoding: URLEncoding.queryString)
            case "FIXED":
                return .requestParameters(parameters: ["menuType": type,
                                                       "menuId": id,
                                                       "page": 0,
                                                       "size": 20,
                                                       "sort": "date,DESC"],
                                          encoding: URLEncoding.queryString)
            default:
                return .requestPlain
            }
        case .report(param: let param):
            return .requestJSONEncodable(param)
        case .deleteReview:
            return .requestPlain
        case .fixReview(_, let param):
            return .requestJSONEncodable(param)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .reviewRate:
            return ["Content-Type":"application/json"]
        default:
            let token = RealmService.shared.getToken()
            if token == "" {
                return ["Content-Type":"application/json"]
            } else {
                return ["Content-Type":"application/json",
                        "Authorization": "Bearer \(token)"]
            }
        }
    }
    
    var authorizationType: Moya.AuthorizationType? {
        switch self {
        default:
            return .bearer
        }
    }
}
