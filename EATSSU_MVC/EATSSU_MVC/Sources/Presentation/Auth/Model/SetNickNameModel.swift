//
//  SetNickNameModel.swift
//  EATSSU_MVC
//
//  Created by Jiwoong CHOI on 11/10/24.
//

import Foundation

import Moya
import PromiseKit

final class SetNickNameModel {
	// MARK: - Propeties

	private let nicknameProvider = MoyaProvider<UserNicknameRouter>(plugins: [MoyaLoggingPlugin()])

	func setUserNickname(nickname: String) -> Promise<Void> {
		return Promise { seal in
			self.nicknameProvider.request(.setNickname(nickname: nickname)) { response in
				switch response {
				case .success(let moyaResponse):
					if let currentUserInfo = UserInfoManager.shared.getCurrentUserInfo() {
						UserInfoManager.shared.updateNickname(for: currentUserInfo, nickname: nickname)
					}

					seal.fulfill(())

				case .failure(let err):
					seal.reject(err)
				}
			}
		}
	}

	func checkNickname(nickname: String) -> Promise<Bool> {
		return Promise { seal in
			self.nicknameProvider.request(.checkNickname(nickname: nickname)) { response in
				switch response {
				case .success(let moyaResponse):
					do {
						let responseData = try moyaResponse.map(BaseResponse<Bool>.self)
						let isSuccess = responseData.result
						seal.fulfill(isSuccess)
					} catch (let err) {
						seal.reject(err)
					}
				case .failure(let err):
					seal.reject(err)
				}
			}
		}
	}
}
