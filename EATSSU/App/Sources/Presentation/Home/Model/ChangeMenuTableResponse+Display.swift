//
//  ChangeMenuTableResponse+Display.swift
//  EATSSU
//
//  Created by 황상환 on 8/30/26.
//

import Foundation

extension ChangeMenuTableResponse {

    /// 현재 앱 언어에서 서버가 대표메뉴 번역을 제공하는지 (규칙은 `AppLanguage.supportsMealTranslation`)
    static var usesTranslatedMainMenus: Bool {
        AppLanguageManager.shared.currentLanguage.supportsMealTranslation
    }

    /// 변동식단(`/meals`, `menus-info`) 조회 시 서버에 넘길 `language` 파라미터.
    /// 서버가 영어 번역만 제공하므로 비한국어 언어는 모두 EN을 요청한다 (한국어는 nil)
    static var mealLanguageParameter: String? {
        let language = AppLanguageManager.shared.currentLanguage
        return language.supportsMealTranslation ? AppLanguage.english.serverCode : nil
    }

    /// 고정메뉴(`/menus`) 조회 시 서버에 넘길 `language` 파라미터. 한국어 외 전부 전달 (EN/JA 번역, VI는 서버가 영어 폴백)
    static var fixedMenuLanguageParameter: String? {
        let language = AppLanguageManager.shared.currentLanguage
        return language.isServerTranslationSupported ? language.serverCode : nil
    }

    /// 화면에 표시할 메뉴 목록
    ///
    /// - 대표메뉴 번역 지원 언어(영어): 서버가 번역해 준 대표메뉴(`isMain == true`)만 표시한다.
    ///   대표메뉴 데이터가 아직 없는 식단은 전부 `isMain == false`로 내려오므로 전체를 그대로(한국어) 표시한다.
    /// - 그 외 언어: 전체 메뉴를 표시한다.
    var displayMenus: [BriefMenus] {
        guard Self.usesTranslatedMainMenus else { return briefMenus }

        let mainMenus = briefMenus.filter { $0.isMain == true }
        return mainMenus.isEmpty ? briefMenus : mainMenus
    }
}
