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
    /// 실제 지원 범위는 API마다 다르다: 리뷰 AI 번역·`/menus`는 EN/JA/VI, `/meals`·`menus-info`는 EN만.
    /// 미지원 조합은 서버가 한국어를 그대로 돌려주고, 대표메뉴 표시는 `isMain` 폴백으로 전체 한국어가 보이므로 안전하다.
    /// 서버가 지원 언어를 넓히면 앱 수정 없이 반영된다.
    var isServerTranslationSupported: Bool {
        self != .korean
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
