//
//  MyPageLocalData.swift
//  EATSSU_MVC
//
//  Created by Jiwoong CHOI on 9/19/24.
//

import Foundation

// TODO: 구조체에 익스텐션으로 코드를 작성하는 이유에 대해서 알아보기

struct MyPageLocalData {
	let titleLabel: String
}

extension MyPageLocalData {
    static let myPageTableLabelList = [
		
		// "푸시 알림 설정"
		MyPageLocalData(titleLabel: TextLiteral.MyPage.pushNotificationSetting),

		// "내가 쓴 리뷰"
		MyPageLocalData(titleLabel: TextLiteral.MyPage.myReview),
				
		// "문의하기"
		MyPageLocalData(titleLabel: TextLiteral.MyPage.inquiry),
		
		// "서비스 이용약관"
		MyPageLocalData(titleLabel: TextLiteral.MyPage.termsOfUse),
		
		// "개인정보 이용약관"
		MyPageLocalData(titleLabel: TextLiteral.MyPage.privacyTermsOfUse),
		
		// "만든 사람들"
		MyPageLocalData(titleLabel: TextLiteral.MyPage.creators),

		// "로그아웃"
		MyPageLocalData(titleLabel: TextLiteral.MyPage.logout),
	]
}
