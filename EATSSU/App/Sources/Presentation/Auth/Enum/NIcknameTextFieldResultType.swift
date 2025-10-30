//
//  NIcknameTextFieldResultType.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 11/8/23.
//

import UIKit

import EATSSUDesign

enum NicknameTextFieldResultType {
    /// common
    case textFieldEmpty
    /// nickname
    case nicknameTextFieldDuplicated
    case nicknameTextFieldDoubleCheck
    case nicknameTextFieldValid
    case invalidLength
    case invalidStartOrEnd
    case consecutiveSpecialChars
    case onlyNumbers
    case invalidCharacters
    case bannedWord
    case whitespaceAtStartOrEnd
    case consecutiveWhitespace
    case emojiOrSpecialChar
    case adminRelatedWord
    case serviceNameWord
    case profanityWord
    
    var hintMessage: String {
        switch self {
        case .textFieldEmpty:
            "필수 입력 사항입니다"
        case .nicknameTextFieldDoubleCheck:
            "중복 확인을 진행해주세요."
        case .nicknameTextFieldDuplicated:
            "이미 사용 중인 닉네임이에요."
        case .nicknameTextFieldValid:
            "사용가능한 닉네임이에요"
        case .invalidLength:
            "2~16글자를 입력해 주세요."
        case .invalidStartOrEnd:
            "특수문자로 시작/끝나는 닉네임은 사용할 수 없어요."
        case .consecutiveSpecialChars:
            "연속된 특수문자(--, __)는 사용할 수 없어요."
        case .onlyNumbers:
            "숫자만으로 된 닉네임은 사용할 수 없어요."
        case .invalidCharacters:
            "허용 문자(한글/영문/숫자)만 사용할 수 있어요."
        case .bannedWord:
            "사용할 수 없는 단어가 포함되어 있어요."
        case .whitespaceAtStartOrEnd:
            "띄어쓰기로 시작/끝나는 닉네임은 사용할 수 없어요."
        case .consecutiveWhitespace:
            "연속된 띄어쓰기는 사용할 수 없어요."
        case .emojiOrSpecialChar:
            "이모지, 특수문자는 사용할 수 없어요."
        case .adminRelatedWord:
            "관리자로 혼동될 수 있는 닉네임은 사용할 수 없어요."
        case .serviceNameWord:
            "서비스명 단독 닉네임은 사용할 수 없어요."
        case .profanityWord:
            "욕설, 비속어 등의 표현이 포함된 닉네임은 사용할 수 없어요."
        }
    }

    var textColor: UIColor {
        switch self {
        case .nicknameTextFieldValid:
            EATSSUDesignAsset.Color.GrayScale.gray600.color
        default:
            .primary
        }
    }

    var borderColor: UIColor {
        switch self {
        case .nicknameTextFieldValid:
            EATSSUDesignAsset.Color.Main.primary.color
        case .textFieldEmpty, .nicknameTextFieldDoubleCheck:
            EATSSUDesignAsset.Color.GrayScale.gray100.color
        default:
            .primary
        }
    }
}
