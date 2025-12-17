//
//  AppFontName.swift
//  EATSSUDesign
//
//  Created by Gemini CLI on 2023/11/27.
//

import UIKit

public enum AppFontName: String {
    case regularFont = "AppleSDGothicNeo-Regular"
    case mediumFont = "AppleSDGothicNeo-Medium"
    case semiBoldFont = "AppleSDGothicNeo-SemiBold"
    case boldFont = "AppleSDGothicNeo-Bold"
    case extraBoldFont = "AppleSDGothicNeo-ExtraBold"

    public var name: String {
        rawValue
    }
}
