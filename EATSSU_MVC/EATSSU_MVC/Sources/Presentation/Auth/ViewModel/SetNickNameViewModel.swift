//
//  SetNickNameViewModel.swift
//  EATSSU
//
//  Created by 최지우 on 2023/07/03.
//

import Foundation
import Moya

class SetNickNameViewModel {
    // Properties
    private let nicknameProvider = MoyaProvider<UserNicknameRouter>(plugins: [MoyaLoggingPlugin()])
    var userNickname: String = ""
    var isNicknameValid: Bool = false
    var nicknameValidationMessage: String = ""
    var nicknameValidationTextColor: UIColor = .gray400

    // Methods
    func checkNicknameAvailability(nickname: String, completion: @escaping (Bool) -> Void) {
        nicknameProvider.request(.checkNickname(nickname: nickname)) { response in
            switch response {
            case let .success(moyaResponse):
                do {
                    let responseData = try moyaResponse.map(BaseResponse<Bool>.self)
                    let isAvailable = responseData.result
                    self.isNicknameValid = isAvailable
                    self.updateNicknameValidationMessage(isAvailable: isAvailable)
                    completion(isAvailable)
                } catch {
                    self.isNicknameValid = false
                    self.updateNicknameValidationMessage(isAvailable: false)
                    completion(false)
                }
            case .failure:
                self.isNicknameValid = false
                self.updateNicknameValidationMessage(isAvailable: false)
                completion(false)
            }
        }
    }

    func setUserNickname(nickname: String, completion: @escaping (Bool) -> Void) {
        nicknameProvider.request(.setNickname(nickname: nickname)) { response in
            switch response {
            case .success:
                self.userNickname = nickname
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }

    private func updateNicknameValidationMessage(isAvailable: Bool) {
        if isAvailable {
            nicknameValidationMessage = "사용 가능한 닉네임이에요"
            nicknameValidationTextColor = .gray700
        } else {
            nicknameValidationMessage = "이미 사용 중인 닉네임이에요"
            nicknameValidationTextColor = .primary
        }
    }
}
