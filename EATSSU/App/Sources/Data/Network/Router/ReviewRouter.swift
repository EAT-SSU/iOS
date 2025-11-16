//
//  ReviewRouter.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/05/22.
//

import Foundation
import Moya

enum ReviewRouter {
    // 상단 메뉴 별점 불러오는 API -> 두개로 쪼개짐. 고정, 변동 분기처리는 아래에서!
    case reviewRate(_ type: String, _ id: Int)

    // 하단 리뷰 리스트 불러오는 API
    case reviewList(_ type: String, _ id: Int)
    case report(param: ReportRequest)
    case deleteReview(_ reviewId: Int)
    case fixReview(_ reviewId: Int, _ param: BeforeSelectedImageDTO)
    
    // MARK: - New V2 API: 리뷰 작성이 가능한 메뉴 목록 조회
    case getValidMenusForReview(_ mealId: Int)
}

extension ReviewRouter: TargetType {
    var baseURL: URL {
        URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case let .reviewRate(type, id):
            switch type {
            case "VARIABLE":
                "/reviews/meals/\(id)"
            case "FIXED":
                "/reviews/menus/\(id)"
            default:
                ""
            }
        case .reviewList:
            "/reviews"
        case .report:
            "/reports"
        case let .deleteReview(reviewId):
            "/reviews/\(reviewId)"
        case let .fixReview(reviewId, _):
            "/reviews/\(reviewId)"
        // MARK: - New V2 Path
        case let .getValidMenusForReview(mealId):
            "/v2/reviews/meal/valid-for-review/\(mealId)" // Path Parameter 사용
        }
    }

    var method: Moya.Method {
        switch self {
        case .reviewRate, .reviewList, .getValidMenusForReview:
            .get
        case .report:
            .post
        case .deleteReview:
            .delete
        case .fixReview:
            .patch
        }
    }

    var task: Moya.Task {
        switch self {
        case let .reviewRate(type, id):
            switch type {
            case "VARIABLE":
                .requestParameters(parameters: ["mealId": id],
                                   encoding: URLEncoding.queryString)
            case "FIXED":
                .requestParameters(parameters: ["menuId": id],
                                   encoding: URLEncoding.queryString)
            default:
                .requestPlain
            }
        /// 이후 정렬 순서, 리뷰 로드 개수 등 수정 필요하면 고치기
        case let .reviewList(type, id):
            switch type {
            case "VARIABLE":
                .requestParameters(parameters: ["menuType": type,
                                                "mealId": id,
                                                "page": 0,
                                                "size": 20,
                                                "sort": "date,DESC"],
                                   encoding: URLEncoding.queryString)
            case "FIXED":
                .requestParameters(parameters: ["menuType": type,
                                                "menuId": id,
                                                "page": 0,
                                                "size": 20,
                                                "sort": "date,DESC"],
                                   encoding: URLEncoding.queryString)
            default:
                .requestPlain
            }
        case let .report(param: param):
            .requestJSONEncodable(param)
        case .deleteReview:
            .requestPlain
        case let .fixReview(_, param):
            .requestJSONEncodable(param)
        
        // MARK: - New V2 Task
        case .getValidMenusForReview: // Path에 ID가 포함되므로 Body나 QueryString 없음
            .requestPlain
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}

extension ReviewRouter {
    var validationType: ValidationType {
        .successCodes
    }
}
