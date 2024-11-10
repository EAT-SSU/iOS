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

	/// EATSSU 서버에 회원가입한 사용자 정보 전송
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

	// TODO: 로그인 로직 간 정확히 무슨 동작을 하는지 파악 후 문서 작성
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

	/// EATSSU 서버에 Apple로 회원가입한 사용자 로그인 전송
	///
	/// - Parameter token : Apple 소셜로그인으로 생성된 토큰값
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
