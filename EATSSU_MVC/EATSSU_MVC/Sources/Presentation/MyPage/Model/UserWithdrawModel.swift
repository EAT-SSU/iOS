//
//  UserWithdrawModel.swift
//  EATSSU
//
//  Created by Jiwoong CHOI on 11/10/24.
//

import Foundation

import Moya

final class UserWithdrawModel {
	private let myProvider = MoyaProvider<MyRouter>(plugins: [MoyaLoggingPlugin()])

	var nickName = ""

	func deleteUser(completion: @escaping () -> Void) {
		self.myProvider.request(.signOut) { response in
			switch response {
			case .success(let moyaResponse):
				do {
					let responseData = try moyaResponse.map(BaseResponse<Bool>.self)
					if responseData.result {
						RealmService.shared.resetDB()

						completion()
					}
				} catch (let err) {
					print(err.localizedDescription)
				}
			case .failure(let err):
				print(err.localizedDescription)
			}
		}
	}
}
