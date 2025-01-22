//
//  UserNicknameRouter.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/08/01.
//
import Foundation

import Moya

enum UserNicknameRouter {
    case setNickname(nickname: String)
    case checkNickname(nickname: String)
}

extension UserNicknameRouter: TargetType, AccessTokenAuthorizable {
    var baseURL: URL {
        URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .setNickname:
            "/users/nickname"
        case .checkNickname:
            "/users/validate/nickname"
        }
    }

    var method: Moya.Method {
        switch self {
        case .setNickname:
            .patch
        case .checkNickname:
            .get
        }
    }

    var task: Moya.Task {
        switch self {
        case let .setNickname(nickname):
            let param: [String: String] = ["nickname": nickname]
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)
        case let .checkNickname(nickname: nickname):
            let param: [String: String] = ["nickname": nickname]
            return .requestParameters(parameters: param, encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        switch self {
        default:
            let realm = RealmService()
            let token = realm.getToken()
            return ["Content-Type": "application/json",
                    "Authorization": "Bearer \(token)"]
        }
    }

    var authorizationType: Moya.AuthorizationType? {
        switch self {
        default:
            .bearer
        }
    }
}
