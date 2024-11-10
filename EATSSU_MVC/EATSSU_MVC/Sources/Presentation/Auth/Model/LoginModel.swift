//
//  LoginModel.swift
//  EATSSU
//
//  Created by Jiwoong CHOI on 11/10/24.
//

import Foundation

import Moya
import PromiseKit

final class LoginModel {
	private let authProvider = MoyaProvider<AuthRouter>(plugins: [MoyaLoggingPlugin()])
	private let myProvider = MoyaProvider<MyRouter>(plugins: [MoyaLoggingPlugin()])

	private func addTokenInRealm(accessToken: String, refreshToken: String) {
		RealmService.shared.addToken(accessToken: accessToken, refreshToken: refreshToken)
		print("⭐️⭐️토큰 저장 성공~⭐️⭐️")
		print(RealmService.shared.getToken())
		print(RealmService.shared.getRefreshToken())
	}

	func checkRealmToken() -> Bool {
		if RealmService.shared.getToken() == "" {
			return false
		} else {
			return true
		}
	}

	func activateFirebaseTask() {
		FirebaseRemoteConfig.shared.fetchIsVacationPeriod()

		#if DEBUG
		#else
		Analytics.logEvent("LoginViewControllerLoad", parameters: nil)
		#endif
	}

	func postKakaoLoginRequest(email: String, id: String) -> Promise<Void> {
		return Promise { seal in
			authProvider.request(.kakaoLogin(param: KakaoLoginRequest(email: email, providerId: id))) { response in
				switch response {
				case .success(let moyaResponse):
					do {
						print(moyaResponse.statusCode)
						let responseData = try moyaResponse.map(BaseResponse<SignResponse>.self)
						self.addTokenInRealm(accessToken: responseData.result.accessToken,
						                     refreshToken: responseData.result.refreshToken)
						let userInfo = UserInfoManager.shared.createUserInfo(accountType: .kakao)
						seal.fulfill(())
					} catch (let err) {
						print(err.localizedDescription)
						seal.reject(err)
					}
				case .failure(let err):
					print(err.localizedDescription)
					seal.reject(err)
				}
			}
		}
	}

	func getMyInfo() -> Promise<BaseResponse<MyInfoResponse>> {
		return Promise { seal in
			myProvider.request(.myInfo) { response in
				switch response {
				case .success(let moyaResponse):
					do {
						let responseData = try moyaResponse.map(BaseResponse<MyInfoResponse>.self)
						seal.fulfill(responseData)
					} catch (let err) {
						print(err.localizedDescription)
					}
				case .failure(let err):
					print(err.localizedDescription)
				}
			}
		}
	}

	func postAppleLoginRequest(token: String) -> Promise<Void> {
		return Promise { seal in
			authProvider.request(.appleLogin(param: AppleLoginRequest(identityToken: token))) { response in
				switch response {
				case .success(let moyaResponse):
					do {
						print(moyaResponse.statusCode)
						let responseData = try JSONDecoder().decode(BaseResponse<SignResponse>.self, from: moyaResponse.data)
						self.addTokenInRealm(accessToken: responseData.result.accessToken,
						                     refreshToken: responseData.result.refreshToken)
						let userInfo = UserInfoManager.shared.createUserInfo(accountType: .apple)
						seal.fulfill(())
					} catch (let err) {
						print(err.localizedDescription)
					}
				case .failure(let err):
					print(err.localizedDescription)
				}
			}
		}
	}
}
