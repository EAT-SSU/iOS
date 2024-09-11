//
//  FontLiteral.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/04/07.
//

import UIKit

enum AppFontName: String {
    
    case regularFont = "AppleSDGothicNeo-Regular"
    case mediumFont = "AppleSDGothicNeo-Medium"
    case semiBoldFont = "AppleSDGothicNeo-SemiBold"
    case boldFont = "AppleSDGothicNeo-Bold"
    case extraBoldFont = "AppleSDGothicNeo-ExtraBold"
    
    var name: String {
        return self.rawValue
    }
}
