//
//  NicknameBannedWords.swift
//  EATSSU
//
//  Created by 황상환 on 10/25/25.
//

import Foundation

struct NicknameBannedWords {
    
    // MARK: - 시스템/운영 관련 금지어
    static let systemWords: [String] = [
        "admin", "관리자",
        "manager", "운영자",
        "system",
    ]
    
    // MARK: - 서비스명/브랜드명
    static let serviceWords: [String] = [
        "eatssu", "EATSSU", "잇슈", "EatSSU"
    ]
    
    // MARK: - 욕설/비속어 (임시 기본 리스트)
    static let profanityWords: [String] = [
        "시발", "씨발", "ㅅㅂ",
        "병신", "ㅂㅅ",
        "개새끼", "ㄱㅅㄲ",
        "존나", "ㅈㄴ",
        "fuck", "shit", "bitch"
        // 필요시 추가
    ]
    
    // MARK: - 전체 금지어 리스트
    static var allBannedWords: [String] {
        return systemWords + serviceWords + profanityWords
    }
    
    // MARK: - 금지어 포함 여부 체크
    static func containsBannedWord(_ nickname: String) -> Bool {
        let lowercased = nickname.lowercased()
        
        return allBannedWords.contains { bannedWord in
            lowercased.contains(bannedWord.lowercased())
        }
    }
    
    // MARK: - 타입별 금지어 체크
    
    /// 관리자/운영자 관련 금지어 체크
    static func containsAdminWord(_ nickname: String) -> Bool {
        let lowercased = nickname.lowercased()
        
        return systemWords.contains { word in
            lowercased.contains(word.lowercased())
        }
    }
    
    /// 서비스명/브랜드명 금지어 체크
    static func containsServiceName(_ nickname: String) -> Bool {
        let lowercased = nickname.lowercased()
        
        return serviceWords.contains { word in
            lowercased.contains(word.lowercased())
        }
    }
    
    /// 욕설/비속어 체크
    static func containsProfanity(_ nickname: String) -> Bool {
        let lowercased = nickname.lowercased()
        
        return profanityWords.contains { word in
            lowercased.contains(word.lowercased())
        }
    }
}
