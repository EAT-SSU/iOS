//
//  UserDepartmentRouter.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 02/23/2025.
//

import Foundation

import Moya

/// 단과대/학부 관련 API 요청을 정의하는 라우터입니다.
///
/// 이 열거형은 사용자 단과대/학부와 관련된 API 요청을 관리합니다.
/// 현재는 단과대/학부를 추가하는 기능을 제공합니다.
enum UserDepartmentRouter {
    /// 단과대/학부 추가 API 요청
    ///
    /// - Parameter departmentName: 추가할 단과대/학부의 이름
    case addDepartment(departmentName: String)

    /// 단과대/학부 검증 API 요청
    case validateDepartment

    /// 사용자 단과대의 제휴업체 요청
    case getUserPartnership
}

extension UserDepartmentRouter: TargetType, AccessTokenAuthorizable {
    /// API의 기본 URL입니다.
    ///
    /// - Returns: `Info.plist`에 정의된 BASE_URL 값을 기반으로 생성된 URL 객체
    var baseURL: URL {
        URL(string: NetworkConfiguration.baseURL)!
    }

    /// 요청할 엔드포인트 경로입니다.
    ///
    /// - Returns: 각 API 요청에 해당하는 경로 문자열
    var path: String {
        switch self {
        case .addDepartment:
            "/users/department"
        case .validateDepartment:
            "/users/validate/department"
        case .getUserPartnership:
            "/users/department/partnerships"
        }
    }

    /// 요청에 사용할 HTTP 메서드입니다.
    ///
    /// - Returns: 각 API 요청에 따라 설정된 HTTP 메서드
    var method: Moya.Method {
        switch self {
        case .addDepartment:
            .post
        case .validateDepartment, .getUserPartnership:
            .get
        }
    }

    /// 요청에 포함할 파라미터 및 인코딩 설정입니다.
    ///
    /// - Returns: 요청에 포함할 파라미터와 인코딩 방식
    var task: Moya.Task {
        switch self {
        case let .addDepartment(departmentName):
            let params: [String: Any] = [
                "departmentName": departmentName,
            ]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        case .validateDepartment, .getUserPartnership:
            return .requestPlain
        }
    }

    /// HTTP 헤더 설정입니다.
    ///
    /// - Returns: 요청에 포함할 HTTP 헤더 (Content-Type 및 Authorization 헤더 포함)
    var headers: [String: String]? {
        switch self {
        default:
            let token = RealmService.shared.getToken()
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(token)",
            ]
        }
    }

    /// 인증 방식 설정입니다.
    ///
    /// - Returns: `Bearer` 인증 방식을 사용합니다.
    var authorizationType: Moya.AuthorizationType? {
        switch self {
        default:
            .bearer
        }
    }
}
