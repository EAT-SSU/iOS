//
//  Logger.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 1/27/25.
//

import Foundation
import Moya

/// 네트워크 로깅을 위한 프로토콜입니다.
///
/// 이 프로토콜을 구현하여 네트워크 요청, 응답 및 오류를 기록할 수 있습니다.
protocol Logger {
    /// 일반 메시지를 로깅합니다.
    ///
    /// - Parameter message: 로깅할 문자열 메시지
    func log(_ message: String)

    /// 네트워크 요청 정보를 로깅합니다.
    ///
    /// - Parameters:
    ///   - request: 전송된 `URLRequest` 객체
    ///   - target: 해당 요청의 `TargetType`
    func logRequest(_ request: URLRequest, target: TargetType)

    /// 네트워크 응답 정보를 로깅합니다.
    ///
    /// - Parameters:
    ///   - response: 수신된 `Response` 객체
    ///   - target: 해당 요청의 `TargetType`
    func logResponse(_ response: Response, target: TargetType)

    /// 네트워크 오류 정보를 로깅합니다.
    ///
    /// - Parameters:
    ///   - error: 발생한 `MoyaError` 객체
    ///   - target: 해당 요청의 `TargetType`
    func logNetworkError(_ error: MoyaError, target: TargetType)
}

/// 기본 네트워크 로깅을 수행하는 구조체입니다.
///
/// `Logger` 프로토콜을 구현하며, 디버그 환경에서 콘솔 출력을 통해 로그를 기록합니다.
struct DefaultLogger: Logger {
    /// 일반 메시지를 로깅합니다.
    ///
    /// - Parameter message: 로깅할 문자열 메시지
    func log(_ message: String) {
        #if DEBUG
            print("📝 [로그]: \(message)")
        #endif
    }

    /// 네트워크 요청 정보를 로깅합니다.
    ///
    /// - Parameters:
    ///   - request: 전송된 `URLRequest` 객체
    ///   - target: 해당 요청의 `TargetType`
    func logRequest(_ request: URLRequest, target: TargetType) {
        var log = """
        ⎡-------------------- 📤 서버 요청 시작 --------------------⎤
        요청 메서드: [\(request.httpMethod ?? "알 수 없음")]
        요청 URL: \(request.url?.absoluteString ?? "알 수 없음")
        API 타겟: \(target)
        """

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            log += "\n요청 헤더:\n\(headers)"
        }
        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8)
        {
            log += "\n요청 바디:\n\(bodyString)"
        }
        log += "\n⎣-------------------- 📤 요청 종료 --------------------⎦"

        #if DEBUG
            print(log)
        #endif
    }

    /// 네트워크 응답 정보를 로깅합니다.
    ///
    /// - Parameters:
    ///   - response: 수신된 `Response` 객체
    ///   - target: 해당 요청의 `TargetType`
    func logResponse(_ response: Response, target: TargetType) {
        var log = """
        ⎡-------------------- 📥 서버 응답 수신 --------------------⎤
        API 타겟: \(target)
        상태 코드: [\(response.statusCode)]
        응답 URL: \(response.request?.url?.absoluteString ?? "알 수 없음")
        """

        if let responseData = String(data: response.data, encoding: .utf8) {
            log += "\n응답 데이터:\n\(responseData)"
        }
        log += "\n⎣-------------------- 📥 응답 종료 (\(response.data.count) 바이트) --------------------⎦"

        #if DEBUG
            print(log)
        #endif
    }

    /// 네트워크 오류 정보를 로깅합니다.
    ///
    /// - Parameters:
    ///   - error: 발생한 `MoyaError` 객체
    ///   - target: 해당 요청의 `TargetType`
    func logNetworkError(_ error: MoyaError, target: TargetType) {
        let log = """
        🚨 네트워크 오류 발생 🚨
        오류 코드: \(error.errorCode)
        API 타겟: \(target)
        오류 설명: \(error.failureReason ?? error.errorDescription ?? "알 수 없는 오류 발생")
        ⎣-------------------- 오류 종료 --------------------⎦
        """

        #if DEBUG
            print(log)
        #endif
    }
}
