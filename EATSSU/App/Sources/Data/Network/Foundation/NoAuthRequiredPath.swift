//
//  NoAuthRequiredPath.swift
//  EATSSU
//
//  Created by 최지우 on 4/21/25.
//

import Foundation

enum NoAuthRequiredPath: String, CaseIterable {
    case kakaoLogin = "oauths/kakao"
    case appleLogin = "oauths/apple"
    case reissuance = "/oauths/reissue/token"
    case getChangeMenuTableResponse = "/meals"
    case getFixedMenuTableResponse = "/menus"
    case variableMenuReviewRate = "/reviews/meals"
    case fixedMenuReviewRate = "/reviews/menus"
    case reviewList = "/reviews"
    
    static func contains(_ path: String) -> Bool {
        return Self.allCases.contains {
            path == $0.rawValue
        }
    }
}
