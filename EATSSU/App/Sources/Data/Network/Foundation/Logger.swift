//
//  Logger.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 1/27/25.
//

import Foundation

import Moya

/// 네트워크 로그 출력을 제어하는 플래그
private let isVerboseNetworkLoggingEnabled = true

/// 네트워크 로깅을 위한 프로토콜
protocol Logger {
    func log(_ message: String)
    func logRequest(_ request: URLRequest, target: TargetType)
    func logResponse(_ response: Response, target: TargetType)
    func logNetworkError(_ error: MoyaError, target: TargetType)
}

/// 기본 네트워크 로거
struct DefaultLogger: Logger {
    func log(_ message: String) {
        #if DEBUG
        print("📝 [로그]: \(message)")
        #endif
    }

    func logRequest(_ request: URLRequest, target: TargetType) {
        guard isVerboseNetworkLoggingEnabled else { return }

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
           let bodyString = String(data: body, encoding: .utf8) {
            log += "\n요청 바디:\n\(bodyString)"
        }

        log += "\n⎣-------------------- 📤 요청 종료 --------------------⎦"

        #if DEBUG
        print(log)
        #endif
    }

    func logResponse(_ response: Response, target: TargetType) {
        guard isVerboseNetworkLoggingEnabled else { return }

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

    func logNetworkError(_ error: MoyaError, target: TargetType) {
        guard isVerboseNetworkLoggingEnabled else { return }

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
