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
            TextLiteral.Auth.requiredInput
        case .nicknameTextFieldDoubleCheck:
            TextLiteral.Auth.needCheckDuplicate
        case .nicknameTextFieldDuplicated:
            TextLiteral.Auth.duplicatedNickname
        case .nicknameTextFieldValid:
            TextLiteral.Auth.availableNickname
        case .invalidLength:
            TextLiteral.Auth.nicknameLength
        case .invalidStartOrEnd:
            TextLiteral.Auth.specialCharNickname
        case .consecutiveSpecialChars:
            TextLiteral.Auth.continuousSpecialChar
        case .onlyNumbers:
            TextLiteral.Auth.numberOnlyNickname
        case .invalidCharacters:
            TextLiteral.Auth.allowedChar
        case .bannedWord:
            TextLiteral.Auth.bannedWord
        case .whitespaceAtStartOrEnd:
            TextLiteral.Auth.spaceNickname
        case .consecutiveWhitespace:
            TextLiteral.Auth.continuousSpace
        case .emojiOrSpecialChar:
            TextLiteral.Auth.emojiSpecialChar
        case .adminRelatedWord:
            TextLiteral.Auth.adminNickname
        case .serviceNameWord:
            TextLiteral.Auth.serviceNameNickname
        case .profanityWord:
            TextLiteral.Auth.slangNickname
        }
    }

    var textColor: UIColor {
        switch self {
        case .nicknameTextFieldValid:
            .gray600
        default:
            .error
        }
    }

    var borderColor: UIColor {
        switch self {
        case .nicknameTextFieldValid:
            .primary
        case .textFieldEmpty, .nicknameTextFieldDoubleCheck:
            .gray100
        default:
            .primary
        }
    }
}
