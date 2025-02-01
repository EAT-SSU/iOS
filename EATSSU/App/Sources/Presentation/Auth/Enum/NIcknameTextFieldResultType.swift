//
//  NIcknameTextFieldResultType.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 11/8/23.
//

import UIKit

/// 닉네임 입력 필드의 상태를 나타내는 열거형입니다.
/// 사용자가 닉네임을 입력할 때 발생할 수 있는 다양한 검증 결과를 정의합니다.
enum NicknameTextFieldResultType {
    /// 사용자가 입력 필드를 비워둔 경우
    case textFieldEmpty

    /// 닉네임이 허용된 길이를 초과한 경우 (예: 2~8자를 벗어남)
    case nicknameTextFieldOver

    /// 닉네임이 중복된 경우 (이미 사용 중인 닉네임)
    case nicknameTextFieldDuplicated

    /// 닉네임 중복 확인이 필요한 경우 (사용자가 중복 확인을 수행하지 않음)
    case nicknameTextFieldDoubleCheck

    /// 사용 가능한 닉네임인 경우
    case nicknameTextFieldValid

    /// 각 상태에 대한 안내 메시지를 반환합니다.
    ///
    /// - Returns: 사용자가 해당 상태에서 확인할 수 있는 힌트 메시지
    var hintMessage: String {
        switch self {
        case .textFieldEmpty:
            "필수 입력 사항입니다" // 닉네임 필드가 비어 있을 때 표시
        case .nicknameTextFieldOver:
            "2~8자내로 입력해주세요" // 닉네임 길이 제한 초과 시 표시
        case .nicknameTextFieldDoubleCheck:
            "중복 확인을 진행해주세요" // 중복 확인 필요할 때 표시
        case .nicknameTextFieldDuplicated:
            "이미 사용 중인 닉네임이에요" // 중복된 닉네임일 때 표시
        case .nicknameTextFieldValid:
            "사용가능한 닉네임이에요" // 닉네임이 사용 가능할 때 표시
        }
    }

    /// 각 상태에 따라 적용되는 텍스트 색상을 반환합니다.
    ///
    /// - Returns: 상태별로 지정된 `UIColor`
    var textColor: UIColor {
        switch self {
        case .textFieldEmpty, .nicknameTextFieldOver, .nicknameTextFieldDuplicated, .nicknameTextFieldDoubleCheck:
            .primary // 오류 및 확인 필요 상태에서 `primary` 색상 적용
        case .nicknameTextFieldValid:
            .gray700 // 유효한 닉네임일 때 `gray700` 색상 적용
        }
    }
}
