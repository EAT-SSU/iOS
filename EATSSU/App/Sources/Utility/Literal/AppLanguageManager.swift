//
//  AppLanguageManager.swift
//  EATSSU
//
//  Created by jeongminji on 5/3/26.
//

import Foundation

final class AppLanguageManager {
    static let shared = AppLanguageManager()

    private init() {}

    private enum Constant {
        /// 사용자가 직접 고른 언어 저장 key
        static let selectedLanguageKey = "selectedAppLanguage"

        /// 사용자가 앱에서 직접 언어를 바꾼 적 있는지 저장  key
        static let didSelectLanguageManuallyKey = "didSelectLanguageManually"
    }

    // MARK: - Current Language
    
    /// 1순위: 사용자가 직접 선택한 언어가 있으면 그걸 우선 사용
    /// 2순위: 사용자가 직접 선택한 적이 없으면 휴대폰 언어 사용
    var currentLanguage: AppLanguage {
        if didSelectLanguageManually,
           let savedLanguageCode = UserDefaults.standard.string(forKey: Constant.selectedLanguageKey),
           let savedLanguage = AppLanguage(rawValue: savedLanguageCode) {
            return savedLanguage
        }

        return deviceLanguage
    }

    var didSelectLanguageManually: Bool {
        return UserDefaults.standard.bool(forKey: Constant.didSelectLanguageManuallyKey)
    }

    private var deviceLanguage: AppLanguage {
        let preferredCode = Locale.preferredLanguages.first ?? "ko"

        if preferredCode.hasPrefix("en") {
            return .english
        } else {
            return .korean
        }
    }

    // MARK: - Bundle

    var bundle: Bundle {
        guard let path = Bundle.main.path(
            forResource: currentLanguage.rawValue,
            ofType: "lproj"
        ),
        let bundle = Bundle(path: path) else {
            return .main
        }

        return bundle
    }

    // MARK: - Change Language

    func changeLanguage(to language: AppLanguage) {
        UserDefaults.standard.set(language.rawValue, forKey: Constant.selectedLanguageKey)
        UserDefaults.standard.set(true, forKey: Constant.didSelectLanguageManuallyKey)
    }
}
