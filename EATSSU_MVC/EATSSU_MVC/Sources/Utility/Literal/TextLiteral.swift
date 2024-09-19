//
//  TextLiteral.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/06/27.
//

import Foundation

/*
 해야 할 일
 - 하위 enum을 사용해서 세분화
 - 마크업 주석으로 해당 리터럴이 의미하는 실제 문자열 기록
 */

// ... existing code ...

enum TextLiteral {

    // MARK: - Notification

    enum Notification {

        /// 🤔 오늘 밥 뭐 먹지…
        static let dailyWeekdayNotificationTitle: String = "🤔 오늘 밥 뭐 먹지…"

        /// 오늘의 학식을 확인해보세요!
        static let dailyWeekdayNotificationBody: String = "오늘의 학식을 확인해보세요!"
    }

    enum KakaoChannel {

        /// EATSSU 카카오 채널 ID
        static let id: String = "_ZlVAn"
    }

    // MARK: - Sign In

    static let signInWithApple: String = "Apple로 로그인"
    static let signInWithKakao: String = "카카오 로그인"
    static let lookingWithNoSignIn: String = "둘러보기"
    static let setNickName: String = "닉네임 설정"
    static let nickNameLabel: String = "닉네임"
    static let inputNickName: String = "닉네임을 입력해주세요"
    static let inputNickNameLabel: String = "닉네임을 설정해 주세요."
    static let doubleCheckNickName: String = "중복확인"
    static let hintInputNickName: String = "2~8글자를 입력해주세요."
    static let completeLabel: String = "완료하기"

	// MARK: - Home
		
	static let menu: String = "오늘의 메뉴"
	static let price: String = "가격"
	static let rating: String = "평점"
	static let emptyRating: String = "  -"
		
	// MARK: - Restaurant
		
	static let dormitoryRestaurant: String = "기숙사 식당"
	static let dodamRestaurant: String = "도담 식당"
	static let studentRestaurant: String = "학생 식당"
	static let snackCorner: String = "스낵 코너"
	static let dormitoryRawValue: String = "DORMITORY"
	static let dodamRawValue: String = "DODAM"
	static let studentRestaurantRawValue: String = "HAKSIK"
	static let snackCornerRawValue: String = "SNACK_CORNER"
	static let lunchRawValue: String = "LUNCH"
	
    // MARK: - MyPage

    /// "마이페이지" 텍스트 리터럴
    enum MyPage {
        
        /// "푸시 알림 설정"
		static let pushNotificationSetting: String = "푸시 알림 설정"
		
        /// "만든사람들"
        static let creators: String = "만든사람들"

        /// "마이페이지
        static let myPage: String = "마이페이지"

        /// "연결된 계정"
        static let linkedAccount: String = "연결된 계정"

        /// "내가 쓴 리뷰"
        static let myReview: String = "내가 쓴 리뷰"

        /// "로그아웃"
        static let logout: String = "로그아웃"

        /// "탈퇴하기"
        static let withdraw: String = "탈퇴하기"

        /// "이용약관"
        static let defaultTerms: String = "이용약관"

        /// "서비스 이용약관"
        static let termsOfUse: String = "서비스 이용약관"

        /// "개인정보 이용약관"
        static let privacyTermsOfUse: String = "개인정보 이용약관"

        /// "앱 버전"
        static let appVersion: String = "앱 버전"

        /// "닉네임 변경"
        static let changeNickname: String = "닉네임 변경"

        /// "새로운 닉네임"
        static let newNickname: String = "새로운 닉네임"

        /// "기존 닉네임"
        static let existingNickname: String = "기존 닉네임"

        /// "문의하기"
        static let inquiry: String = "문의하기"

        /// "정말 탈퇴하시겠습니까?"
        static let confirmWithdrawal: String = "정말 탈퇴하시겠습니까?"

        /// "작성한 리뷰 게시글은 삭제되지 않으며, (알수없음)으로 표시됩니다.\n자세한 내용은 서비스이용약관 및 개인정보처리방침을 확인해 주세요."
        static let withdrawalNotice: String =
            "작성한 리뷰 게시글은 삭제되지 않으며, (알수없음)으로 표시됩니다.\n자세한 내용은 서비스이용약관 및 개인정보처리방침을 확인해 주세요."

        /// "올바른 입력입니다."
        static let validInputMessage: String = "올바른 입력입니다"

        /// "올바르지 않은 닉네임입니다"
        static let invalidNicknameMessage: String = "올바르지 않은 닉네임입니다"
    }
}
