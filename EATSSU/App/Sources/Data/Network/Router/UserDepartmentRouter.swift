//
//  UserDepartmentRouter.swift
//  EATSSUNetwork
//
//  Created by JIWOONG CHOI on [작성일].
//

import Foundation
import Moya

// TODO: App 모듈 안에 UserRouter의 역할을 하는 코드가 있을 것. 해당 코드를 EATSSUNetwork로 이관.

/// 부서 관련 API 요청을 정의합니다.
enum UserDepartmentRouter {
    /// 부서 추가 API 요청
    case addDepartment(departmentName: String)
}

extension UserDepartmentRouter: TargetType, AccessTokenAuthorizable {
    var authorizationType: Moya.AuthorizationType? {
        switch self {
        default:
            .bearer
        }
    }

    /// API 기본 URL (Info.plist의 BASE_URL 값을 사용합니다.)
    var baseURL: URL {
        URL(string: AppConfiguration.baseURL)!
    }

    /// 엔드포인트 경로 설정
    var path: String {
        switch self {
        case .addDepartment:
            "/users/department"
        }
    }

    /// HTTP 메서드 설정 (POST)
    var method: Moya.Method {
        switch self {
        case .addDepartment:
            .post
        }
    }

    /// 요청 Task 설정 (JSON 인코딩을 사용한 파라미터 전송)
    var task: Moya.Task {
        switch self {
        case let .addDepartment(departmentName):
            let params: [String: Any] = [
                "departmentName": departmentName,
            ]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }

    /// HTTP 헤더 설정 (JSON 기반 요청)
    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}
