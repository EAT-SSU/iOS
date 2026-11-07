//
//  PushTokenRouter.swift
//  EATSSU
//
//  Created by 황상환 on 10/17/26.
//

import Foundation

import Moya

/// 푸시 토큰 API (로그인 필요). 서버는 토큰 등록 여부로 알림 허용 여부를 판단한다
enum PushTokenRouter {
    /// 등록·갱신. 다른 계정에 등록된 토큰이면 현재 계정으로 옮겨진다
    case register(token: String)
    /// 삭제. 등록되지 않은 토큰이어도 성공
    case unregister(token: String)
}

extension PushTokenRouter: TargetType {
    var baseURL: URL {
        URL(string: Config.baseURL)!
    }

    var path: String {
        "/users/push-token"
    }

    var method: Moya.Method {
        switch self {
        case .register:
            .put
        case .unregister:
            .delete
        }
    }

    var task: Moya.Task {
        switch self {
        case let .register(token):
            .requestParameters(parameters: ["token": token, "deviceType": "IOS"], encoding: JSONEncoding.default)
        case let .unregister(token):
            .requestParameters(parameters: ["token": token], encoding: JSONEncoding.default)
        }
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }

    var validationType: ValidationType {
        .successCodes
    }
}
