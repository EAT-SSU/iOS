//
//  AuthRouter.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/05/27.
//

import Foundation

import Moya

enum AuthRouter {
    case kakaoLogin(param: KakaoLoginRequest)
    case appleLogin(param: AppleLoginRequest)
}

extension AuthRouter: TargetType {
    public var baseURL: URL {
        URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .kakaoLogin:
            "/oauths/v2/kakao"
        case .appleLogin:
            "/oauths/v2/apple"
        }
    }

    var method: Moya.Method {
        switch self {
        case .kakaoLogin:
            .post
        case .appleLogin:
            .post
        }
    }

    var task: Task {
        switch self {
        case let .kakaoLogin(param: param):
            .requestJSONEncodable(param)
        case let .appleLogin(param: param):
            .requestJSONEncodable(param)
        }
    }

    var headers: [String: String]? {
        switch self {
        default:
            ["Content-Type": "application/json"]
        }
    }
}
