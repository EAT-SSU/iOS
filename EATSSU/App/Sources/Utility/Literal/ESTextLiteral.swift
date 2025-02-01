//
//  ESTextLiteral.swift
//  EATSSU
//
//  Edited by Jiwoong CHOI on 01/30/2025.
//

import Foundation

/// 애플리케이션 내에서 사용되는 모든 텍스트 리터럴을 관리하는 열거형입니다.
enum ESTextLiteral {
    // MARK: - Notification

    enum Notification {
        /// 일상적인 평일 식사 알림의 제목입니다.
        /// - Note: "🤔 오늘 밥 뭐 먹지…"
        static let dailyWeekdayNotificationTitle: String = "🤔 오늘 밥 뭐 먹지…"

        /// 일상적인 평일 식사 알림의 본문 메시지입니다.
        /// - Note: "오늘의 학식을 확인해보세요!"
        static let dailyWeekdayNotificationBody: String = "오늘의 학식을 확인해보세요!"
    }

    // MARK: - Map

    enum Map {
        /// 제휴 지도에서 사용하는 네비게이션 타이틀입니다.
        /// - Note: "지도"
        static let mapNavTitle: String = "지도"
    }

    // MARK: - KakaoChannel

    enum KakaoChannel {
        /// EATSSU 카카오 채널의 고유 ID입니다.
        /// - Note: "_ZlVAn"
        static let id: String = "_ZlVAn"
    }

    // MARK: - Sign In

    enum SignIn {
        /// Apple 계정을 통한 로그인 버튼의 텍스트입니다.
        /// - Note: "Apple로 로그인"
        static let signInWithApple: String = "Apple로 로그인"

        /// 카카오 계정을 통한 로그인 버튼의 텍스트입니다.
        /// - Note: "카카오 로그인"
        static let signInWithKakao: String = "카카오 로그인"

        /// 로그인을 하지 않고 앱을 둘러보는 버튼의 텍스트입니다.
        /// - Note: "둘러보기"
        static let lookingWithNoSignIn: String = "둘러보기"
    }

    // MARK: - Nickname

    enum Nickname {
        /// 닉네임 설정 화면의 타이틀 텍스트입니다.
        /// - Note: "닉네임 설정"
        static let setNickName: String = "닉네임 설정"

        /// 닉네임 입력 필드의 레이블 텍스트입니다.
        /// - Note: "닉네임"
        static let nickNameLabel: String = "닉네임"

        /// 닉네임 입력 필드의 플레이스홀더 텍스트입니다.
        /// - Note: "닉네임을 입력해주세요"
        static let inputNickName: String = "닉네임을 입력해주세요"

        /// 닉네임 설정 안내 메시지의 텍스트입니다.
        /// - Note: "닉네임을 설정해 주세요."
        static let inputNickNameLabel: String = "닉네임을 설정해 주세요."

        /// 닉네임 중복 확인 버튼의 텍스트입니다.
        /// - Note: "중복확인"
        static let doubleCheckNickName: String = "중복확인"

        /// 닉네임 입력 힌트 메시지의 텍스트입니다.
        /// - Note: "2~8글자를 입력해주세요."
        static let hintInputNickName: String = "2~8글자를 입력해주세요."

        /// 닉네임 설정 완료 버튼의 텍스트입니다.
        /// - Note: "완료하기"
        static let completeLabel: String = "완료하기"

        /// 닉네임 변경 버튼의 텍스트입니다.
        /// - Note: "닉네임 변경"
        static let changeNickname: String = "닉네임 변경"

        /// 새로운 닉네임을 입력하는 필드의 레이블 텍스트입니다.
        /// - Note: "새로운 닉네임"
        static let newNickname: String = "새로운 닉네임"

        /// 기존 닉네임을 표시하는 레이블의 텍스트입니다.
        /// - Note: "기존 닉네임"
        static let existingNickname: String = "기존 닉네임"

        /// 올바른 입력 시 표시되는 성공 메시지의 텍스트입니다.
        /// - Note: "올바른 입력입니다"
        static let validInputMessage: String = "올바른 입력입니다"

        /// 올바르지 않은 닉네임 입력 시 표시되는 오류 메시지의 텍스트입니다.
        /// - Note: "올바르지 않은 닉네임입니다"
        static let invalidNicknameMessage: String = "올바르지 않은 닉네임입니다"
    }

    // MARK: - Home

    enum Home {
        /// 홈 화면에서 오늘의 메뉴를 표시하는 섹션의 타이틀입니다.
        /// - Note: "오늘의 메뉴"
        static let todayMenu: String = "오늘의 메뉴"

        /// 메뉴 가격을 표시하는 레이블의 텍스트입니다.
        /// - Note: "가격"
        static let price: String = "가격"

        /// 메뉴 평점을 표시하는 레이블의 텍스트입니다.
        /// - Note: "평점"
        static let rating: String = "평점"

        /// 평점이 없는 경우 표시되는 텍스트입니다.
        /// - Note: "  -"
        static let emptyRating: String = "  -"

        /// 제공되는 메뉴가 없을 때 표시되는 메시지입니다.
        /// - Note: "제공되는 메뉴가 없습니다"
        static let noMenuProvidedMessage: String = "제공되는 메뉴가 없습니다"
    }

    // MARK: - Restaurant

    enum Restaurant {
        /// 기숙사 식당의 이름을 나타내는 텍스트입니다.
        /// - Note: "기숙사 식당"
        static let dormitoryRestaurant: String = "기숙사 식당"

        /// 도담 식당의 이름을 나타내는 텍스트입니다.
        /// - Note: "도담 식당"
        static let dodamRestaurant: String = "도담 식당"

        /// 학생 식당의 이름을 나타내는 텍스트입니다.
        /// - Note: "학생 식당"
        static let studentRestaurant: String = "학생 식당"

        /// 스낵 코너의 이름을 나타내는 텍스트입니다.
        /// - Note: "스낵 코너"
        static let snackCorner: String = "스낵 코너"

        /// 기숙사 식당의 식별자 값입니다.
        /// - Note: "DORMITORY"
        static let dormitoryRawValue: String = "DORMITORY"

        /// 도담 식당의 식별자 값입니다.
        /// - Note: "DODAM"
        static let dodamRawValue: String = "DODAM"

        /// 학생 식당의 식별자 값입니다.
        /// - Note: "HAKSIK"
        static let studentRestaurantRawValue: String = "HAKSIK"

        /// 스낵 코너의 식별자 값입니다.
        /// - Note: "SNACK_CORNER"
        static let snackCornerRawValue: String = "SNACK_CORNER"

        /// 점심 식사의 식별자 값입니다.
        /// - Note: "LUNCH"
        static let lunchRawValue: String = "LUNCH"
    }

    // MARK: - MyPage

    enum MyPage {
        /// 변경하기 값입니다.
        /// - Note: "변경하기"
        static let change: String = "변경하기"

        /// 완료하기 값입니다.
        /// - Note: "완료하기"
        static let complete: String = "완료하기"

        /// 소속설정 UILabel의 값입니다.
        /// - Note: "소속 설정"
        static let affiliationSetting: String = "소속 설정"

        /// 알림 수신 권한 설정을 요청하는 메시지 텍스트입니다.
        /// - Note: "설정에서 알림수신을 동의해주세요!"
        static let authorizeNotificationSettingMessage: String = "설정에서 알림수신을 동의해주세요!"

        /// 푸시 알림 사용자 설정 접근을 위한 키입니다.
        /// - Note: "pushNotificationUserSettingKey"
        static let pushNotificationUserSettingKey: String = "pushNotificationUserSettingKey"

        /// 푸시 알림 설정 화면의 타이틀 텍스트입니다.
        /// - Note: "푸시 알림 설정"
        static let pushNotificationSetting: String = "푸시 알림 설정"

        /// 내 정보를 수정하는 VC의 타이틀입니다.
        /// - Note: "내 정보 수정"
        static let myInfoTitle: String = "내 정보 수정"

        /// 제작자 목록을 표시하는 섹션의 타이틀 텍스트입니다.
        /// - Note: "만든사람들"
        static let creators: String = "만든사람들"

        /// 마이페이지 화면의 타이틀 텍스트입니다.
        /// - Note: "마이페이지"
        static let myPage: String = "마이페이지"

        /// 연결된 계정을 관리하는 섹션의 타이틀 텍스트입니다.
        /// - Note: "연결된 계정"
        static let linkedAccount: String = "연결된 계정"

        /// 사용자가 작성한 리뷰를 표시하는 섹션의 타이틀 텍스트입니다.
        /// - Note: "내가 쓴 리뷰"
        static let myReview: String = "내가 쓴 리뷰"

        /// 로그아웃 버튼의 텍스트입니다.
        /// - Note: "로그아웃"
        static let logout: String = "로그아웃"

        /// 계정을 탈퇴하는 버튼의 텍스트입니다.
        /// - Note: "탈퇴하기"
        static let withdraw: String = "탈퇴하기"

        /// 기본 이용 약관의 텍스트입니다.
        /// - Note: "이용약관"
        static let defaultTerms: String = "이용약관"

        /// 서비스 이용 약관의 텍스트입니다.
        /// - Note: "서비스 이용약관"
        static let termsOfUse: String = "서비스 이용약관"

        /// 개인정보 처리 방침의 텍스트입니다.
        /// - Note: "개인정보 이용약관"
        static let privacyTermsOfUse: String = "개인정보 이용약관"

        /// 앱의 버전 정보를 표시하는 레이블의 텍스트입니다.
        /// - Note: "앱 버전"
        static let appVersion: String = "앱 버전"

        /// 문의하기 버튼의 텍스트입니다.
        /// - Note: "문의하기"
        static let inquiry: String = "문의하기"

        /// 계정 탈퇴 확인을 위한 알림 메시지의 텍스트입니다.
        /// - Note: "정말 탈퇴하시겠습니까?"
        static let confirmWithdrawal: String = "정말 탈퇴하시겠습니까?"

        /// 계정 탈퇴 시 리뷰 게시글 처리에 대한 공지 메시지의 텍스트입니다.
        /// - Note: "작성한 리뷰 게시글은 삭제되지 않으며, (알수없음)으로 표시됩니다.\n자세한 내용은 서비스이용약관 및 개인정보처리방침을 확인해 주세요."
        static let withdrawalNotice: String =
            "작성한 리뷰 게시글은 삭제되지 않으며, (알수없음)으로 표시됩니다.\n자세한 내용은 서비스이용약관 및 개인정보처리방침을 확인해 주세요."
    }
}
