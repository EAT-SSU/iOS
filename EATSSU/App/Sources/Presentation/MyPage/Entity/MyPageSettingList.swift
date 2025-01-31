//
//  MyPageSettingList.swift
//  EATSSU
//
//  Created by Jiwoong CHOI on 9/19/24.
//

import Foundation

struct MyPageSettingList {
    let title: String
}

extension MyPageSettingList {
    static let myPageTableLabelList = [
        // "푸시 알림 설정"
        MyPageSettingList(title: ESTextLiteral.MyPage.pushNotificationSetting),

        // "내 정보"
        MyPageSettingList(title: ESTextLiteral.MyPage.myInfoTitle),

        // "내가 쓴 리뷰"
        MyPageSettingList(title: ESTextLiteral.MyPage.myReview),

        // "문의하기"
        MyPageSettingList(title: ESTextLiteral.MyPage.inquiry),

        // "서비스 이용약관"
        MyPageSettingList(title: ESTextLiteral.MyPage.termsOfUse),

        // "개인정보 이용약관"
        MyPageSettingList(title: ESTextLiteral.MyPage.privacyTermsOfUse),

        // "만든 사람들"
        MyPageSettingList(title: ESTextLiteral.MyPage.creators),

        // "로그아웃"
        MyPageSettingList(title: ESTextLiteral.MyPage.logout),
    ]
}
