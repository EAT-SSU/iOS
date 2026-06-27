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
