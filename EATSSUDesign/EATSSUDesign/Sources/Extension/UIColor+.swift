//
//  UIColor+.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/02/13.
//

import UIKit

public extension UIColor {
    
    // MARK: - GrayScale
    
    static var gray100: UIColor { EATSSUDesignAsset.Color.GrayScale.gray100.color }
    static var gray200: UIColor { EATSSUDesignAsset.Color.GrayScale.gray200.color }
    static var gray300: UIColor { EATSSUDesignAsset.Color.GrayScale.gray300.color }
    static var gray400: UIColor { EATSSUDesignAsset.Color.GrayScale.gray400.color }
    static var gray500: UIColor { EATSSUDesignAsset.Color.GrayScale.gray500.color }
    static var gray600: UIColor { EATSSUDesignAsset.Color.GrayScale.gray600.color }
    static var gray700: UIColor { EATSSUDesignAsset.Color.GrayScale.gray700.color }
    
    /// Tuist Asset에 없는 컬러라 hex 값으로 유지
    static var gray700Basic: UIColor { UIColor(hex: "#1F1F1F") }

    // MARK: - Main
    
    static var primary: UIColor { EATSSUDesignAsset.Color.Main.primary.color }
    static var secondary: UIColor { EATSSUDesignAsset.Color.Main.secondary.color }
    static var festivalPrimary: UIColor { EATSSUDesignAsset.Color.Main.festivalPrimary.color }

    // MARK: - Dialog & Status (These are flat directly under EATSSUDesignAsset.Color)
    
    static var danger: UIColor { EATSSUDesignAsset.Color.danger.color }
    static var dangerBg: UIColor { EATSSUDesignAsset.Color.dangerBg.color }
    static var dangerBr: UIColor { EATSSUDesignAsset.Color.dangerBr.color }
    static var info: UIColor { EATSSUDesignAsset.Color.info.color }
    static var infoBg: UIColor { EATSSUDesignAsset.Color.infoBg.color }
    static var infoBr: UIColor { EATSSUDesignAsset.Color.infoBr.color }
    static var success: UIColor { EATSSUDesignAsset.Color.success.color }
    static var successBg: UIColor { EATSSUDesignAsset.Color.successBg.color }
    static var successBr: UIColor { EATSSUDesignAsset.Color.successBr.color }
    static var warning: UIColor { EATSSUDesignAsset.Color.warning.color }
    static var warningBg: UIColor { EATSSUDesignAsset.Color.warningBg.color }
    static var warningBr: UIColor { EATSSUDesignAsset.Color.warningBr.color }

    // MARK: - Red
    static var error: UIColor { EATSSUDesignAsset.Color.Red.error.color }
    
    // MARK: - Yellow
    static var star: UIColor { EATSSUDesignAsset.Color.Yellow.star.color }
    
    // MARK: - Gradation
    static var highGradation: UIColor { EATSSUDesignAsset.Color.Gradation.highGradation.color }
    static var lowGradation: UIColor { EATSSUDesignAsset.Color.Gradation.lowGradation.color }

    // MARK: - Hex Initializer
    
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }

        assert(hexFormatted.count == 6, "Invalid hex code used.")
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0, alpha: alpha)
    }
}