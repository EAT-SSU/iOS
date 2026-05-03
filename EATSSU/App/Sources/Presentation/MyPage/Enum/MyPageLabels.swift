//
//  MyPageLabels.swift
//  EATSSU
//
//  Created by Jiwoong CHOI on 9/11/24.
//

import Foundation

/// "마이페이지"에서 확인할 수 있는 서비스 리스트
enum MyPageLabels {
    case notificationSetting
    case myInfo
    case myReview
    case inquiry
    case creators
    case instagram
    case languageSetting
    case termsAndPolicy
    case logout
    
    var title: String {
        switch self {
        case .notificationSetting:
            return TextLiteral.MyPage.pushNotificationSetting
        case .myInfo:
            return TextLiteral.MyPage.myInfo
        case .myReview:
            return TextLiteral.MyPage.myReview
        case .inquiry:
            return TextLiteral.MyPage.inquiry
        case .creators:
            return TextLiteral.MyPage.creators
        case .instagram:
            return TextLiteral.MyPage.instagram
        case .languageSetting:
            return TextLiteral.MyPage.languageSetting
        case .termsAndPolicy:
            return TextLiteral.MyPage.termsAndPolicy
        case .logout:
            return TextLiteral.MyPage.logout
        }
    }
    
    var subtitle: String? {
        switch self {
        case .notificationSetting:
            return TextLiteral.MyPage.pushNotificationDescription
        default:
            return nil
        }
    }
    
    var rightText: String? {
        switch self {
        case .languageSetting:
            return TextLiteral.MyPage.currentLanguage
        default:
            return nil
        }
    }
    
    var showsDisclosure: Bool {
        switch self {
        case .notificationSetting, .logout:
            return false
        default:
            return true
        }
    }
}
