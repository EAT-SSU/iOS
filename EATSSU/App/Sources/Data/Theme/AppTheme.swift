//
//  AppTheme.swift
//  EATSSU
//
//  Created by Claude on 2026/04/03.
//

import UIKit

import EATSSUDesign

enum AppTheme: String, CaseIterable, Codable {
    case `default` = "default"
    case christmas = "christmas"
    case spring = "spring"

    /// Info.plist CFBundleAlternateIcons에 등록된 이름. nil이면 기본 아이콘.
    var alternateIconName: String? {
        switch self {
        case .default: return nil
        case .christmas: return "AppIcon_christmas"
        case .spring: return "AppIcon_spring"
        }
    }

    var splashLogoImage: UIImage {
        switch self {
        case .default, .spring:
            return EATSSUDesignAsset.Images.splashLogo.image
        case .christmas:
            return EATSSUDesignAsset.Images.splashChristmasLogo.image
        }
    }

    var splashBackgroundImage: UIImage? {
        switch self {
        case .default: return nil
        case .christmas: return EATSSUDesignAsset.Images.splashChistmasBackground.image
        case .spring: return EATSSUDesignAsset.Images.splashSpringBackground.image
        }
    }

    var splashBackgroundColor: UIColor {
        switch self {
        case .default: return .primary
        case .christmas, .spring: return .clear
        }
    }

    /// Alert에 표시할 테마 이름
    var displayName: String {
        switch self {
        case .default: return "기본 테마"
        case .christmas: return "크리스마스 테마"
        case .spring: return "봄 테마"
        }
    }

    /// Alert에 표시할 아이콘 미리보기 이미지
    /// Asset Catalog 기반 alternate icon은 UIImage(named:)으로 접근 불가하므로 nil 반환
    var iconPreviewImage: UIImage? {
        return nil
    }
}
