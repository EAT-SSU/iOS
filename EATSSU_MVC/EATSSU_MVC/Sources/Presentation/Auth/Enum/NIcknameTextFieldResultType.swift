//
//  NIcknameTextFieldResultType.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 11/8/23.
//

import UIKit

enum NicknameTextFieldResultType {
    
    /// common
    case textFieldEmpty
    /// nickname
    case nicknameTextFieldOver
    case nicknameTextFieldDuplicated
    case nicknameTextFieldDoubleCheck
    case nicknameTextFieldValid
    
    var hintMessage: String {
        switch self {
        case .textFieldEmpty:
            return "필수 입력 사항입니다"
        case .nicknameTextFieldOver:
            return "2~8자내로 입력해주세요"
        case .nicknameTextFieldDoubleCheck:
            return "중복 확인을 진행해주세요"
        case .nicknameTextFieldDuplicated:
            return "이미 사용 중인 닉네임이에요"
        case .nicknameTextFieldValid:
            return "사용가능한 닉네임이에요"
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .textFieldEmpty, .nicknameTextFieldOver, .nicknameTextFieldDuplicated, .nicknameTextFieldDoubleCheck:
            return .primary
        case .nicknameTextFieldValid:
            return .gray700
        }
    }
    
}

