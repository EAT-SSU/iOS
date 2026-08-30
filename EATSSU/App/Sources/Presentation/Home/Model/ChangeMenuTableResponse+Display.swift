//
//  ChangeMenuTableResponse+Display.swift
//  EATSSU
//
//  Created by 황상환 on 8/30/26.
//

import Foundation

extension ChangeMenuTableResponse {

    /// 서버가 대표메뉴 번역을 제공하는 앱 언어인지 (현재 영어만 지원)
    static var usesTranslatedMainMenus: Bool {
        AppLanguageManager.shared.currentLanguage == .english
    }

    /// 변동식단 조회 시 서버에 넘길 `language` 파라미터. 번역 미지원 언어는 nil(한국어 응답)
    static var mealLanguageParameter: String? {
        usesTranslatedMainMenus ? AppLanguage.english.rawValue.uppercased() : nil
    }

    /// 화면에 표시할 메뉴 목록
    ///
    /// - 번역 지원 언어(영어): 서버가 번역해 준 대표메뉴(`isMain == true`)만 표시한다.
    ///   대표메뉴 데이터가 아직 없는 식단은 전부 `isMain == false`로 내려오므로 전체를 그대로(한국어) 표시한다.
    /// - 그 외 언어: 전체 메뉴를 표시한다.
    var displayMenus: [BriefMenus] {
        guard Self.usesTranslatedMainMenus else { return briefMenus }

        let mainMenus = briefMenus.filter { $0.isMain == true }
        return mainMenus.isEmpty ? briefMenus : mainMenus
    }
}
