//
//  ESMoyaLogginPlugin.swift
//  EATSSU
//
//  Edited by Jiwoong CHOI on 01/27/2025.
//

import UIKit

import EATSSUNetwork

import Moya

/// `ESMoyaLoggingPlugin`은 네트워크 요청 및 응답을 로깅하고,
/// 인증 토큰의 유효성 검사 및 재발급을 처리하는 Moya 플러그인입니다.
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
            handleSuccess(response, target: target)
        case let .failure(error):
            handleFailure(error, target: target)
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

    // MARK: - Private Methods

    /// 성공적인 응답을 처리하는 메서드입니다.
    ///
    /// - Parameters:
    ///   - response: 성공적인 `Response` 객체
    ///   - target: 요청의 대상 `TargetType`
    private func handleSuccess(_ response: Response, target: TargetType) {
        logger.logResponse(response, target: target)

        switch response.statusCode {
        case 401, 403:
            logger.log("인증이 만료되었습니다. 토큰을 재발급합니다.")
            reissueToken()
        default:
            logger.log("응답 상태 코드: \(response.statusCode) - 정상 처리되었습니다.")
        }
    }

    /// 실패한 응답을 처리하는 메서드입니다.
    ///
    /// - Parameters:
    ///   - error: Moya 네트워크 오류
    ///   - target: 요청의 대상 `TargetType`
    private func handleFailure(_ error: MoyaError, target: TargetType) {
        if let response = error.response {
            handleSuccess(response, target: target)
            return
        }
        logger.logNetworkError(error, target: target)
    }

    /// 토큰 재발급을 수행하는 메서드입니다.
    private func reissueToken() {
        logger.log("토큰 재발급 요청을 시작합니다.")
        reissueProvider.request(.reissuance) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(response):
                handleReissueSuccess(response)
            case let .failure(error):
                handleReissueFailure(error)
            }
        }
    }

    /// 토큰 재발급 성공 시 처리하는 메서드입니다.
    ///
    /// - Parameter response: 토큰 재발급 성공 응답
    private func handleReissueSuccess(_ response: Response) {
        do {
            let baseResponse = try response.map(BaseResponse<SignResponse>.self)
            addTokenToRealm(accessToken: baseResponse.result.accessToken,
                            refreshToken: baseResponse.result.refreshToken)
            logger.log("토큰이 성공적으로 재발급되었습니다.")
        } catch {
            logger.log("토큰 재발급 응답 처리 중 오류 발생: \(error.localizedDescription)")
        }
    }

    /// 토큰 재발급 실패 시 처리하는 메서드입니다.
    ///
    /// - Parameter error: 토큰 재발급 실패 오류
    private func handleReissueFailure(_ error: MoyaError) {
        switch error {
        case let .statusCode(response) where response.statusCode == 403:
            logger.log("토큰 재발급 실패: 접근이 거부되었습니다. 로그인 화면으로 이동합니다.")
            handleTokenExpiry()
        case let .underlying(_, response):
            logger.log("서버 연결 오류가 발생했습니다. 로그인 화면으로 이동합니다.")
            handleUnderlyingError(response: response)
        default:
            logger.log("토큰 재발급 중 알 수 없는 오류 발생: \(error.localizedDescription)")
        }
    }

    /// 토큰 만료 시 로그인 화면으로 이동하는 메서드입니다.
    private func handleTokenExpiry() {
        logger.log("토큰 만료로 인해 데이터를 초기화하고 로그인 화면으로 이동합니다.")
        RealmService.shared.resetDB()
        navigateToLogin()
    }

    /// 네트워크 문제가 발생했을 때 로그인 화면으로 이동하는 메서드입니다.
    private func handleUnderlyingError(response _: Response?) {
        logger.log("네트워크 문제가 발생했습니다. 데이터를 초기화하고 로그인 화면으로 이동합니다.")
        RealmService.shared.resetDB()
        navigateToLogin()
    }

    /// 새 토큰을 로컬 데이터베이스에 저장하는 메서드입니다.
    ///
    /// - Parameters:
    ///   - accessToken: 액세스 토큰
    ///   - refreshToken: 리프레시 토큰
    private func addTokenToRealm(accessToken: String, refreshToken: String) {
        RealmService.shared.addToken(accessToken: accessToken, refreshToken: refreshToken)
        logger.log("새로운 토큰이 성공적으로 저장되었습니다.")
    }

    /// 로그인 화면으로 이동하는 메서드입니다.
    private func navigateToLogin() {
        logger.log("로그인 화면으로 이동합니다.")
        let loginVC = LoginViewController()
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
            {
                keyWindow.replaceRootViewController(UINavigationController(rootViewController: loginVC))
            }
        }
    }
}
