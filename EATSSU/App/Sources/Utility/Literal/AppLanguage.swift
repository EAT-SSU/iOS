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

    var title: String {
        switch self {
        case .korean:
            return "한국어"
        case .english:
            return "English"
        }
    }
}
