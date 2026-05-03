//
//  MyPageSectionData.swift
//  EATSSU
//
//  Created by jeongminji on 5/3/26.
//

import Foundation

struct MyPageSectionData {
    let headerTitle: String
    let items: [MyPageLabels]
}

extension MyPageSectionData {
    static var sections: [MyPageSectionData] {
        [
            MyPageSectionData(
                headerTitle: TextLiteral.MyPage.activitySection,
                items: [
                    .notificationSetting,
                    .myInfo,
                    .myReview
                ]
            ),
            MyPageSectionData(
                headerTitle: TextLiteral.MyPage.serviceInfoSection,
                items: [
                    .inquiry,
                    .creators,
                    .instagram
                ]
            ),
            MyPageSectionData(
                headerTitle: TextLiteral.MyPage.etcSection,
                items: [
                    .languageSetting,
                    .termsAndPolicy,
                    .logout
                ]
            )
        ]
    }
}
