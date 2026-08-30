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

    /// 서버에 번역을 요청할 언어인지 (한국어 제외 전부)
    ///
    /// 리뷰 AI 번역(`/v2/reviews/{id}/translate`)과 고정메뉴(`/menus`)가 EN/JA/VI를 지원한다.
    /// (`/menus`의 VI는 서버가 영어로 폴백)
    var isServerTranslationSupported: Bool {
        self != .korean
    }

    /// 변동식단(`/meals`, `/meals/{mealId}/menus-info`) 대표메뉴 번역을 서버가 제공하는 언어인지. 현재 영어만
    ///
    /// 미지원 언어를 보내면 서버가 한국어를 돌려주긴 하지만, 대표메뉴만 표시하는 규칙이 잘못 켜지지 않도록
    /// 식단 API는 이 조건으로만 언어를 전달한다. 서버가 지원을 넓히면 여기만 수정한다.
    var supportsMealTranslation: Bool {
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
