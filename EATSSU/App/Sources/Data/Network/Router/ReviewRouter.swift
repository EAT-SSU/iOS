//
//  ReviewRouter.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/05/22.
//

import Foundation
import Moya

enum ReviewRouter {
    case report(param: ReportRequest)
    case deleteReview(_ reviewId: Int)
    
    // MARK: - New V2 API
    case getValidMenusForReview(_ mealId: Int)
    case newReviewList(_ type: String,
                       _ id: Int,
                       lastReviewId: Int?,
                       page: Int? = 0,
                       size: Int? = 20)
    case getFixedMenuStatistics(_ menuId: Int)
    case getMealStatistics(_ mealId: Int)
    case translateReview(_ reviewId: Int, language: String)
}

extension ReviewRouter: TargetType {
    var baseURL: URL {
        URL(string: Config.baseURL)!
    }
    
    var path: String {
        switch self {
        case .report:
            "/reports"
        case let .deleteReview(reviewId):
            "/v2/reviews/\(reviewId)"
            // MARK: - New V2 Path
        case let .getValidMenusForReview(mealId):
            "/v2/reviews/meal/valid-for-review/\(mealId)"
        case .newReviewList(let type, _, _, _, _):
            switch type {
            case "VARIABLE":
                "/v2/reviews/list/meal"
            case "FIXED":
                "/v2/reviews/list/menu"
            default:
                ""
            }
        case let .getFixedMenuStatistics(menuId):
            "/v2/reviews/statistics/menus/\(menuId)"
        case let .getMealStatistics(mealId):
            "/v2/reviews/statistics/meals/\(mealId)"
        case let .translateReview(reviewId, _):
            "/v2/reviews/\(reviewId)/translate"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getValidMenusForReview, .newReviewList, .getFixedMenuStatistics, .getMealStatistics:
                .get
        case .report, .translateReview:
                .post
        case .deleteReview:
                .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case let .report(param: param):
                .requestJSONEncodable(param)
        case .deleteReview:
                .requestPlain
            
            // MARK: - New V2 Task
        case .getValidMenusForReview:
                .requestPlain
        case let .newReviewList(type, id, lastReviewId, page, size):
            switch type {
            case "VARIABLE":
                .requestParameters(
                    parameters: {
                        var dict: [String: Any] = [
                            "mealId": id,
                            "size": size ?? 20
                        ]

                        if let lastId = lastReviewId {
                            dict["lastReviewId"] = lastId
                        }
                        
                        return dict
                    }(),
                    encoding: URLEncoding.queryString
                )
                
            case "FIXED":
                    .requestParameters(
                        parameters: ["menuId": id, "page": page ?? 0, "size": size ?? 20],
                        encoding: URLEncoding.queryString
                    )
                
            default:
                    .requestPlain
                
            }
        case .getFixedMenuStatistics:
                .requestPlain
        case .getMealStatistics:
                .requestPlain
        case let .translateReview(_, language):
                .requestParameters(
                    parameters: ["language": language],
                    encoding: URLEncoding.queryString
                )
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
