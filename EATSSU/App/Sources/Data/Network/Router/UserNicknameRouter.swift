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
    case setDepartment(department: String)
}

extension UserNicknameRouter: TargetType {
    var baseURL: URL {
        URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .setNickname:
            "/users/nickname"
        case .checkNickname:
            "/users/validate/nickname"
        case .setDepartment:
            "/users/department"
        }
    }

    var method: Moya.Method {
        switch self {
        case .setNickname:
            .patch
        case .checkNickname:
            .get
        case .setDepartment:
            .post
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
        case let .setDepartment(department: department):
            let param: [String: String] = ["departmentName": department]
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }

}

extension UserNicknameRouter {
    var validationType: ValidationType {
       return .successCodes
    }
}
