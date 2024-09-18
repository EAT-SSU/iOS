//
//  MyPageLabels.swift
//  EATSSU
//
//  Created by Jiwoong CHOI on 9/11/24.
//

import Foundation

/// "마이파이지"에서 확인할 수 있는 서비스 리스트
enum MyPageLabels : Int {
  
  /// 내가 쓴 리뷰
  case MyReview = 0
  
  /// 문의하기
  case Inquiry
  
  /// 서비스 이용약관
  case TermsOfUse
  
  /// 개인정보 이용약관
  case PrivacyTermsOfUse
  
  /// 로그아웃
  case Logout
  
  /// 탈퇴하기
  case Withdraw
  
  /// 만든사람들
  case Creator
  
  /// 앱버전
  case AppVersion
}
