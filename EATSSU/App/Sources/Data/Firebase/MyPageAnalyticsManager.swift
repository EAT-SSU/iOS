//
//  MyPageAnalyticsManager.swift
//  EATSSU
//
//  Created by 황상환 on 2026/05/23.
//

import Foundation

/// 마이페이지에서 발생하는 주요 이벤트를 Firebase Analytics에 로깅하는 담당자
final class MyPageAnalyticsManager {

    // MARK: - Singleton

    static let shared = MyPageAnalyticsManager()
    private init() {}

    // MARK: - Event & Parameter Keys

    private enum Event {
        static let clickMyPageMenu = "click_mypage_menu"
    }

    private enum Parameter {
        static let menu = "menu"
        static let college = "college"
        static let major = "major"
    }

    /// click_mypage_menu 이벤트의 menu 파라미터 값
    enum Menu: String {
        case notificationSetting = "notification_setting"
        case myInfo = "my_info"
        case myReview = "my_review"
        case inquiry = "inquiry"
        case termsOfUse = "terms_of_use"
        case privacyPolicy = "privacy_policy"
        case creator = "creator"
        case logout = "logout"
        case withdraw = "withdraw"
    }

    // MARK: - Logging Methods

    /// 마이페이지의 메뉴 항목을 클릭했을 때 호출
    /// - Parameter menu: 클릭한 메뉴 종류
    func logClickMyPageMenu(menu: Menu) {
        var parameters: [String: Any] = [Parameter.menu: menu.rawValue]

        let userInfo = UserInfoManager.shared.getCurrentUserInfo()
        if let collegeId = userInfo?.collegeId {
            parameters[Parameter.college] = collegeId
        }
        if let departmentId = userInfo?.departmentId {
            parameters[Parameter.major] = departmentId
        }

        AnalyticsService.logEvent(Event.clickMyPageMenu, parameters: parameters)
    }
}
