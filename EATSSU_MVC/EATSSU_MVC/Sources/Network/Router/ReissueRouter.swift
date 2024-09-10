//
//  ReissueRouter.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 11/12/23.
//

import Foundation
import Moya

enum ReissueRouter {
    case reissuance
}

extension ReissueRouter: TargetType, AccessTokenAuthorizable {
    var baseURL: URL {
        return URL(string: Config.baseURL)!
    }
    
    var path: String {
        switch self {
        case .reissuance:
            return "/oauths/reissue/token"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .reissuance:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .reissuance:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        default:
            let realm = RealmService()
            let refreshToken = realm.getRefreshToken()
            return ["Content-Type": "application/json",
                    "Authorization": "Bearer \(refreshToken)"]
        }
    }
    
    var authorizationType: Moya.AuthorizationType? {
        switch self {
        default:
            return .bearer
        }
    }
}

extension ReissueRouter {
  var validationType: ValidationType {
      return .successCodes
  }
}
