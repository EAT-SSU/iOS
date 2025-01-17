//
//  MoyaPluggin.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/05/31.
//

import UIKit

import Moya

final class MoyaLoggingPlugin: PluginType {
    private let reissueProvider = MoyaProvider<ReissueRouter>()

    func prepare(_ request: URLRequest, target _: TargetType) -> URLRequest {
        request
    }

    // Request를 보낼 때 호출
    func willSend(_ request: RequestType, target: TargetType) {
        guard let httpRequest = request.request else {
            print("--> 유효하지 않은 요청")
            return
        }

        let url = httpRequest.description
        let method = httpRequest.httpMethod ?? "메소드값이 nil입니다."
        var log = """
        ⎡---------------------서버통신을 시작합니다.----------------------⎤
        [\(method)] \(url)
        API: \(target) \n
        """
        if let headers = httpRequest.allHTTPHeaderFields, !headers.isEmpty {
            log.append("header:\n \(headers) \n")
        }
        if let body = httpRequest.httpBody, let bodyString = String(bytes: body, encoding: String.Encoding.utf8) {
            log.append("\(bodyString)\n")
        }

        log.append("⎣------------------ Request END  -------------------------⎦")
        print(log)
    }

    // Response가 왔을 때
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case let .success(response):
            onSucceed(response, target: target, isFromError: false)
        case let .failure(error):
            onFail(error, target: target)
        }
    }

    func process(_ result: Result<Response, MoyaError>, target _: TargetType) -> Result<Response, MoyaError> {
        result
    }

    func onSucceed(_ response: Response, target: TargetType, isFromError _: Bool) {
        let request = response.request
        let url = request?.url?.absoluteString ?? "nil"
        let statusCode = response.statusCode
        var log = "⎡------------------서버에게 Response가 도착했습니다. ------------------⎤\n"
        log.append("API: \(target)\n")
        log.append("Status Code: [\(statusCode)]\n")
        log.append("URL: \(url)\n")
        if let responseData = String(bytes: response.data, encoding: String.Encoding.utf8) {
            log.append("Data: \n  \(responseData)\n")
        }
        log.append("⎣------------------ END HTTP (\(response.data.count)-byte body) ------------------⎦")
        print(log)

        // 🔥 401 인 경우 리프레쉬 토큰 + 액세스 토큰 을 가지고 갱신 시도
        switch statusCode {
        case 401:
            userTokenReissueWithAPI()
        case 403:
            // 🔥 토큰 갱신 서버통신 메서드.
            userTokenReissueWithAPI()
        default:
            return
        }
    }

    func onFail(_ error: MoyaError, target: TargetType) {
        if let response = error.response {
            onSucceed(response, target: target, isFromError: true)
            return
        }
        var log = "네트워크 오류"
        log.append("<-- \(error.errorCode) \(target)\n")
        log.append("\(error.failureReason ?? error.errorDescription ?? "unknown error")\n")
        log.append("<-- END HTTP")
        print(log)
    }
}

// 🔥 Network

extension MoyaLoggingPlugin {
    func userTokenReissueWithAPI() {
        reissueProvider.request(.reissuance) { response in
            switch response {
            case let .success(data):
                do {
                    // 성공적으로 토큰 갱신
                    print("✅✅✅✅✅✅✅✅✅✅✅\(data)")
                    let responseData = try data.map(BaseResponse<SignResponse>.self)
                    print("✅✅✅✅✅✅✅✅✅✅✅\(responseData)")
                    self.addTokenInRealm(accessToken: responseData.result.accessToken,
                                         refreshToken: responseData.result.refreshToken)
                    print("userTokenReissueWithAPI - success")
                } catch {
                    print("Error while parsing response: \(error)")
                }

            case let .failure(error):
                switch error {
                // HTTP 상태 코드 에러 처리
                case let .statusCode(response):
                    print("🌙statusCode")
                    if response.statusCode == 403 {
                        // 기존에는 여기서 리프레쉬 토큰 만료 처리 해줘야 함.
                    }
                    print("userTokenReissueWithAPI - requestErr: \(response.statusCode)")
                // 다른 에러 처리
                case let .underlying(_, response):
                    print("userTokenReissueWithAPI - underlying error: \(response?.statusCode ?? 0)")
                    RealmService.shared.resetDB()

                    // 로그인 뷰로 화면 전환 로직.
                    let loginViewController = LoginViewController()
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
                    {
                        keyWindow.replaceRootViewController(UINavigationController(rootViewController: loginViewController))
                    }
                // 그 외 에러 처리
                default:
                    print("userTokenReissueWithAPI - other error: \(error)")
                }
            }
        }
    }

    private func addTokenInRealm(accessToken: String, refreshToken: String) {
        RealmService.shared.addToken(accessToken: accessToken, refreshToken: refreshToken)
        print("⭐️⭐️토큰 저장 성공~⭐️⭐️")
        print(RealmService.shared.getToken())
    }
}
