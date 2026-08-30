//
//  AppLanguage.swift
//  EATSSU
//
//  Created by jeongminji on 5/3/26.
//

import Foundation

enum AppLanguage: String, CaseIterable {
    case korean = "ko"
    case english = "en"
    case japanese = "ja"
    case vietnamese = "vi"

    /// 서버 API에 전달하는 언어 코드 (예: "EN")
    var serverCode: String {
        rawValue.uppercased()
    }

    /// 서버가 번역(리뷰 AI 번역, 변동식단 대표메뉴 영문명)을 제공하는 언어인지. 현재 영어만 지원
    var isServerTranslationSupported: Bool {
        self == .english
    }

    var title: String {
        switch self {
        case .korean:
            return "한국어"
        case .english:
            return "English"
        case .japanese:
            return "日本語"
        case .vietnamese:
            return "Tiếng Việt"
        }
    }
}
