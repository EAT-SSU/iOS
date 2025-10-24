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
    case invalidLength
    case invalidStartOrEnd          
    case consecutiveSpecialChars
    case onlyNumbers
    case invalidCharacters
    
    var hintMessage: String {
        switch self {
        case .textFieldEmpty:
            "필수 입력 사항입니다"
        case .nicknameTextFieldOver:
            "2~8자내로 입력해주세요"
        case .nicknameTextFieldDoubleCheck:
            "중복 확인을 진행해주세요"
        case .nicknameTextFieldDuplicated:
            "이미 사용 중인 닉네임이에요"
        case .nicknameTextFieldValid:
            "사용가능한 닉네임이에요"
        case .invalidLength:
            "1~16자로 입력해주세요"
        case .invalidStartOrEnd:
            "한글, 영문, 숫자로 시작하고 끝나야 해요"
        case .consecutiveSpecialChars:
            "특수문자(-, _, 공백)는 연속으로 사용할 수 없어요"
        case .onlyNumbers:
            "숫자로만 구성할 수 없어요"
        case .invalidCharacters:
            "한글, 영문, 숫자, -, _, 공백만 사용 가능해요"
        }
    }

    var textColor: UIColor {
        switch self {
        case .textFieldEmpty, .nicknameTextFieldOver, .nicknameTextFieldDuplicated, .nicknameTextFieldDoubleCheck,
             .invalidLength, .invalidStartOrEnd, .consecutiveSpecialChars, .onlyNumbers, .invalidCharacters:
            .primary
        case .nicknameTextFieldValid:
            .gray700
        }
    }
}
