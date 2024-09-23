//
//  AuthRouter.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/05/27.
//

import Foundation
import Moya

enum AuthRouter {
    case signUp(param: SignUpRequest)
    case signIn(param: SignInRequest)
    case kakaoLogin(param: KakaoLoginRequest)
    case appleLogin(param: AppleLoginRequest)
}

extension AuthRouter: TargetType {
  public var baseURL: URL {
      return URL(string: Config.baseURL)!
  }
  
  var path: String {
    switch self {
    case .signUp:
        return "/user/join"
    case .signIn:
        return "/user/login"
    case .kakaoLogin:
        return "/oauths/kakao"
    case .appleLogin:
        return "/oauths/apple"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .signUp:
      return .post
    case .signIn:
        return .post
    case .kakaoLogin:
        return .post
    case .appleLogin:
        return .post
    }
  }
  
  var task: Task {
    switch self {
    case .signUp(let param):
        return .requestJSONEncodable(param)
    case .signIn(let param):
        return .requestJSONEncodable(param)
    case .kakaoLogin(param: let param):
        return .requestJSONEncodable(param)
    case .appleLogin(param: let param):
        return .requestJSONEncodable(param)
    }
  }

  var headers: [String: String]? {
    switch self {
    default:
      return ["Content-Type": "application/json"]
    }
  }
}
