//
//  NicknameValidator.swift
//  EATSSU
//
//  Created by 황상환 on 10/24/25.
//

import Foundation

final class NicknameValidator {
    
    // MARK: - Validation Methods
    
    /// 닉네임 유효성 검사 (모든 규칙 체크)
    static func validate(_ nickname: String) -> NicknameTextFieldResultType? {
        // 빈 문자열 체크
        if nickname.isEmpty {
            return .textFieldEmpty
        }
        
        // 길이 체크 (1~16자)
        if !(1...16).contains(nickname.count) {
            return .invalidLength
        }
        
        // 허용되지 않은 문자 체크
        if !isAllowedCharacters(nickname) {
            return .invalidCharacters
        }
        
        // 시작과 끝이 한글(초성포함), 영문, 숫자인지 체크
        if !isValidStartAndEnd(nickname) {
            return .invalidStartOrEnd
        }
        
        // 특수문자 연속 사용 체크
        if hasConsecutiveSpecialChars(nickname) {
            return .consecutiveSpecialChars
        }
        
        // 숫자로만 구성되었는지 체크
        if isOnlyNumbers(nickname) {
            return .onlyNumbers
        }
        
        // 모든 검사 통과 - 중복 확인 필요
        return .nicknameTextFieldDoubleCheck
    }
    
    // MARK: - Private Helper Methods
    
    /// 허용된 문자만 포함되어 있는지 체크 (한글(초성포함), 영문, 숫자, -, _, 공백)
    private static func isAllowedCharacters(_ nickname: String) -> Bool {
        var allowed = CharacterSet()
        
        // 영문 소문자
        allowed.formUnion(CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz"))
        // 영문 대문자
        allowed.formUnion(CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ"))
        // 숫자
        allowed.formUnion(CharacterSet.decimalDigits)
        // 한글 (완성된 글자)
        allowed.formUnion(CharacterSet(charactersIn: "가".unicodeScalars.first!..."힣".unicodeScalars.first!))
        // 한글 자음
        allowed.formUnion(CharacterSet(charactersIn: "ㄱ".unicodeScalars.first!..."ㅎ".unicodeScalars.first!))
        // 한글 모음
        allowed.formUnion(CharacterSet(charactersIn: "ㅏ".unicodeScalars.first!..."ㅣ".unicodeScalars.first!))
        // 특수문자
        allowed.formUnion(CharacterSet(charactersIn: "-_ "))
        
        return nickname.unicodeScalars.allSatisfy { allowed.contains($0) }
    }
    
    /// 시작과 끝이 한글(초성포함), 영문, 숫자인지 체크
    private static func isValidStartAndEnd(_ nickname: String) -> Bool {
        guard let first = nickname.first, let last = nickname.last else {
            return false
        }
        
        var valid = CharacterSet()
        
        // 영문 소문자
        valid.formUnion(CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz"))
        // 영문 대문자
        valid.formUnion(CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ"))
        // 숫자
        valid.formUnion(CharacterSet.decimalDigits)
        // 한글 (완성된 글자)
        valid.formUnion(CharacterSet(charactersIn: "가".unicodeScalars.first!..."힣".unicodeScalars.first!))
        // 한글 자음
        valid.formUnion(CharacterSet(charactersIn: "ㄱ".unicodeScalars.first!..."ㅎ".unicodeScalars.first!))
        // 한글 모음
        valid.formUnion(CharacterSet(charactersIn: "ㅏ".unicodeScalars.first!..."ㅣ".unicodeScalars.first!))
        
        let firstString = String(first)
        let lastString = String(last)
        
        let isFirstValid = firstString.unicodeScalars.allSatisfy { valid.contains($0) }
        let isLastValid = lastString.unicodeScalars.allSatisfy { valid.contains($0) }
        
        return isFirstValid && isLastValid
    }
    
    /// 특수문자(-, _, 공백)가 연속으로 사용되었는지 체크
    private static func hasConsecutiveSpecialChars(_ nickname: String) -> Bool {
        let specialChars: [Character] = ["-", "_", " "]
        
        for i in 0..<nickname.count - 1 {
            let currentIndex = nickname.index(nickname.startIndex, offsetBy: i)
            let nextIndex = nickname.index(nickname.startIndex, offsetBy: i + 1)
            
            let currentChar = nickname[currentIndex]
            let nextChar = nickname[nextIndex]
            
            if specialChars.contains(currentChar) && specialChars.contains(nextChar) {
                return true
            }
        }
        
        return false
    }
    
    /// 숫자로만 구성되어 있는지 체크
    private static func isOnlyNumbers(_ nickname: String) -> Bool {
        return nickname.allSatisfy { $0.isNumber }
    }
}
