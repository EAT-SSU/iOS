//
//  AuthRouter.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/05/27.
//

import Foundation

import EATSSUNetwork

import Moya

enum AuthRouter {
    case signUp(param: SignUpRequest)
    case signIn(param: SignInRequest)
    case kakaoLogin(param: KakaoLoginRequest)
    case appleLogin(param: AppleLoginRequest)
}

extension AuthRouter: TargetType {
    public var baseURL: URL {
        URL(string: AppConfiguration.baseURL)!
    }

    var path: String {
        switch self {
        case .signUp:
            "/user/join"
        case .signIn:
            "/user/login"
        case .kakaoLogin:
            "/oauths/kakao"
        case .appleLogin:
            "/oauths/apple"
        }
    }

    var method: Moya.Method {
        switch self {
        case .signUp:
            .post
        case .signIn:
            .post
        case .kakaoLogin:
            .post
        case .appleLogin:
            .post
        }
    }

    var task: Task {
        switch self {
        case let .signUp(param):
            .requestJSONEncodable(param)
        case let .signIn(param):
            .requestJSONEncodable(param)
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
