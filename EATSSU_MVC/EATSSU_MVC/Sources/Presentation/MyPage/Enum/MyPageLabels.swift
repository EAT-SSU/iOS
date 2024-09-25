//
//  MyPageLabels.swift
//  EATSSU
//
//  Created by Jiwoong CHOI on 9/11/24.
//

import Foundation

/// "마이파이지"에서 확인할 수 있는 서비스 리스트
enum MyPageLabels : Int {
  	/// 푸시 알림 설정
	case NotificationSetting = 0
	
	/// 내가 쓴 리뷰
	case MyReview
	
	/// 문의하기
	case Inquiry
  
	/// 서비스 이용약관
	case TermsOfUse
  
	/// 개인정보 이용약관
	case PrivacyTermsOfUse
	  
	/// 만든사람들
	case Creator
	
	/// 로그아웃
	case Logout
}
