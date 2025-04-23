//
//  ESMoyaLogginPlugin.swift
//  EATSSU
//
//  Edited by Jiwoong CHOI on 01/27/2025.
//

import UIKit

import Moya

/// `ESMoyaLoggingPlugin`은 네트워크 요청 및 응답을 로깅
final class ESMoyaLoggingPlugin: PluginType {
    // MARK: - Properties

    /// 토큰 재발급을 위한 MoyaProvider 인스턴스입니다.
    private let reissueProvider: MoyaProvider<ReissueRouter>

    /// 네트워크 요청 및 응답을 기록하는 로거입니다.
    private let logger: Logger

    // MARK: - Initialization

    /// `ESMoyaLoggingPlugin`의 초기화 메서드입니다.
    ///
    /// - Parameters:
    ///   - reissueProvider: 토큰 재발급을 위한 `MoyaProvider<ReissueRouter>` 인스턴스 (기본값: `MoyaProvider<ReissueRouter>()`)
    ///   - logger: 네트워크 로그 출력을 위한 `Logger` 인스턴스 (기본값: `DefaultLogger()`)
    init(reissueProvider: MoyaProvider<ReissueRouter> = MoyaProvider<ReissueRouter>(),
         logger: Logger = DefaultLogger())
    {
        self.reissueProvider = reissueProvider
        self.logger = logger
    }

    // MARK: - PluginType Methods

    /// 요청을 전처리하는 메서드입니다.
    ///
    /// - Parameters:
    ///   - request: 원래의 `URLRequest`
    ///   - target: 요청의 대상 `TargetType`
    /// - Returns: 수정된 `URLRequest`
    func prepare(_ request: URLRequest, target _: TargetType) -> URLRequest {
        request
    }

    /// 네트워크 요청이 전송되기 전에 호출됩니다.
    ///
    /// - Parameters:
    ///   - request: 전송될 요청 객체
    ///   - target: 요청 대상의 `TargetType`
    func willSend(_ request: RequestType, target: TargetType) {
        guard let httpRequest = request.request else {
            logger.log("잘못된 요청입니다.")
            return
        }
        logger.logRequest(httpRequest, target: target)
    }

    /// 네트워크 응답을 처리하는 메서드입니다.
    ///
    /// - Parameters:
    ///   - result: 네트워크 요청의 결과 (`Result<Response, MoyaError>`)
    ///   - target: 요청의 대상 `TargetType`
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case let .success(response):
            logger.logResponse(response, target: target)
        case let .failure(error):
            logger.logNetworkError(error, target: target)
        }
    }

    /// 네트워크 결과를 후처리하는 메서드입니다.
    ///
    /// - Parameters:
    ///   - result: 네트워크 요청의 결과
    ///   - target: 요청 대상의 `TargetType`
    /// - Returns: 후처리된 네트워크 응답 결과
    func process(_ result: Result<Response, MoyaError>, target _: TargetType) -> Result<Response, MoyaError> {
        result
    }

}
