//
//  AppLanguageSandbox.swift
//  EATSSUUnitTests
//
//  Created by 황상환 on 8/31/26.
//

import Foundation

@testable import EATSSU_DEV

/// 테스트에서 앱 언어를 바꾸고, 종료 시 원래 UserDefaults 상태로 되돌리는 헬퍼
/// (AppLanguageManager가 UserDefaults를 직접 읽으므로 테스트 간 오염을 막는다)
final class AppLanguageSandbox {

    private enum Key {
        static let selected = "selectedAppLanguage"
        static let manual = "didSelectLanguageManually"
    }

    private let savedLanguage: String?
    private let savedManualFlag: Bool

    init() {
        savedLanguage = UserDefaults.standard.string(forKey: Key.selected)
        savedManualFlag = UserDefaults.standard.bool(forKey: Key.manual)
    }

    func set(_ language: AppLanguage) {
        AppLanguageManager.shared.changeLanguage(to: language)
    }

    func restore() {
        if let savedLanguage {
            UserDefaults.standard.set(savedLanguage, forKey: Key.selected)
        } else {
            UserDefaults.standard.removeObject(forKey: Key.selected)
        }
        UserDefaults.standard.set(savedManualFlag, forKey: Key.manual)
    }
}
