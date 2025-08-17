//
//  UIColor+.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/02/13.
//

import UIKit

extension UIColor {
    static var gray100: UIColor {
        UIColor(hex: "#F9F9F9")
    }

    static var gray200: UIColor {
        UIColor(hex: "#E6E6E6")
    }

    static var gray300: UIColor {
        UIColor(hex: "#D9D9D9")
    }

    static var gray500: UIColor {
        UIColor(hex: "#9D9D9D")
    }

    static var gray700: UIColor {
        UIColor(hex: "#565656")
    }
    
    static var gray700Basic: UIColor {
        UIColor(hex: "#1F1F1F")
    }

    static var primary: UIColor {
        UIColor(hex: "#DF5757")
    }
}

extension UIColor {
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
