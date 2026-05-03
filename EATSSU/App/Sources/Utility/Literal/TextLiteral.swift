//
//  TextLiteral.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/06/27.
//

import Foundation

private enum Localization {
    static func localized(
        _ key: String,
        fallback: String
    ) -> String {
        let value = AppLanguageManager.shared.bundle.localizedString(
            forKey: key,
            value: fallback,
            table: nil
        )

        return value
    }
    
    static func formatted(
        _ key: String,
        fallback: String,
        _ arguments: CVarArg...
    ) -> String {
        let format = localized(key, fallback: fallback)

        return String(
            format: format,
            locale: Locale(identifier: AppLanguageManager.shared.currentLanguage.rawValue),
            arguments: arguments
        )
    }
}

enum TextLiteral {
    // MARK: - KakaoChannel

    enum KakaoChannel {
        /// EATSSU 카카오 채널 ID
        static let id: String = "_ZlVAn"
    }

    // MARK: - Common
    
    enum Common {
        /// "확인"
        static var logoSubTitle: String {
            Localization.localized("common.logoSubTitle", fallback: "숭실대에서 먹자")
        }
        /// "확인"
        static var confirm: String {
            Localization.localized("common.confirm", fallback: "확인")
        }
        
        /// "취소"
        static var cancel: String {
            Localization.localized("common.cancel", fallback: "취소")
        }
        
        /// "취소하기"
        static var cancelDark: String {
            Localization.localized("common.cancelDark", fallback: "취소하기")
        }
        
        /// "삭제하기"
        static var delete: String {
            Localization.localized("common.delete", fallback: "삭제하기")
        }
        
        /// "수정하기"
        static var fix: String {
            Localization.localized("common.fix", fallback: "수정하기")
        }

        /// "로그인이 필요한 서비스입니다"
        static var needLogin: String {
            Localization.localized("common.needLogin", fallback: "로그인이 필요한 서비스입니다")
        }
        
        /// "로그인 하시겠습니까?"
        static var askLogin: String {
            Localization.localized("common.askLogin", fallback: "로그인 하시겠습니까?")
        }
        
        /// "설정으로 이동"
        static var moveToSetting: String {
            Localization.localized("common.moveToSetting", fallback: "설정으로 이동")
        }
        
        /// "탈퇴 처리가 완료되었습니다."
        static var withdrawComplete: String {
            Localization.localized("common.withdrawComplete", fallback: "탈퇴 처리가 완료되었습니다.")
        }
        
        /// "잠시 후 다시 시도해주세요."
        static var tryAgain: String {
            Localization.localized("common.tryAgain", fallback: "잠시 후 다시 시도해주세요.")
        }
        
        /// "세션이 만료되었습니다. 다시 로그인해주세요."
        static var sessionExpired: String {
            Localization.localized("common.sessionExpired", fallback: "세션이 만료되었습니다. 다시 로그인해주세요.")
        }

        /// "에러가 발생했습니다"
        static var errorOccured: String {
            Localization.localized("common.errorOccured", fallback: "에러가 발생했습니다")
        }
        
        /// "다시 시도하세요"
        static var retry: String {
            Localization.localized("common.retry", fallback: "다시 시도하세요")
        }
    }
    
    // MARK: - TabBar
    
    enum TabBar {
        /// "학식"
        static var meal: String {
            Localization.localized("tabBar.meal", fallback: "학식")
        }
        
        /// "지도"
        static var map: String {
            Localization.localized("tabBar.map", fallback: "지도")
        }
        
        /// "나만아니면돼~"
        static var coffee: String {
            Localization.localized("tabBar.coffee", fallback: "나만아니면돼~")
        }

        /// "마이"
        static var my: String {
            Localization.localized("tabBar.my", fallback: "마이")
        }
    }

    // MARK: - Auth
    
    enum Auth {
        /// "닉네임을 입력해주세요"
        static var inputNickName: String {
            Localization.localized("auth.inputNickName", fallback: "닉네임을 입력해주세요")
        }

        /// "Apple로 로그인"
        static var signInWithApple: String {
            Localization.localized("auth.signInWithApple", fallback: "Apple로 로그인")
        }
        
        /// "카카오 로그인"
        static var signInWithKakao: String {
            Localization.localized("auth.signInWithKakao", fallback: "카카오 로그인")
        }

        /// "둘러보기"
        static var lookingWithNoSignIn: String {
            Localization.localized("auth.lookingWithNoSignIn", fallback: "둘러보기")
        }

        /// UserDefaults key for last login provider
        static let lastLoginProviderKey: String = "lastLoginProvider"

        /// "최근에 로그인했어요"
        static var lastLoginTooltip: String {
            Localization.localized("auth.lastLoginTooltip", fallback: "최근에 로그인했어요")
        }

        /// LoginVC - "카카오톡으로 생성된 계정입니다."
        static var kakaoAccount: String {
            Localization.localized("auth.kakaoAccount", fallback: "카카오톡으로 생성된 계정입니다.")
        }

        /// LoginVC - "Apple로 생성된 계정입니다."
        static var appleAccount: String {
            Localization.localized("auth.appleAccount", fallback: "Apple로 생성된 계정입니다.")
        }

        /// SetNickNameView - "닉네임 설정"
        static var setNickname: String {
            Localization.localized("auth.setNickname", fallback: "닉네임 설정")
        }

        /// SetNickNameView - "중복 확인"
        static var checkDuplicate: String {
            Localization.localized("auth.checkDuplicate", fallback: "중복 확인")
        }
        
        /// SetNickNameView - "소속 설정"
        static var setCollege: String {
            Localization.localized("auth.setCollege", fallback: "소속 설정")
        }

        /// SetNickNameView - "단과대"
        static var college: String {
            Localization.localized("auth.college", fallback: "단과대")
        }

        /// SetNickNameView - "학과"
        static var department: String {
            Localization.localized("auth.department", fallback: "학과")
        }
        
        /// SetNickNameView - "연결된 계정"
        static var linkedAccount: String {
            Localization.localized("auth.linkedAccount", fallback: "연결된 계정")
        }

        /// SetNickNameView - "없음"
        static var empty: String {
            Localization.localized("auth.empty", fallback: "없음")
        }
        
        /// SetNickNameView - "저장하기"
        static var save: String {
            Localization.localized("auth.save", fallback: "저장하기")
        }

        /// SetNickNameView - "카카오"
        static var kakao: String {
            Localization.localized("auth.kakao", fallback: "카카오")
        }

        /// SetNickNameView - "APPLE"
        static var apple: String {
            Localization.localized("auth.apple", fallback: "APPLE")
        }
        
        /// SetNickNameVC - "변경된 정보가 없습니다."
        static var noChanges: String {
            Localization.localized("auth.noChanges", fallback: "변경된 정보가 없습니다.")
        }
        
        /// SetNickNameVC - "유효하지 않은 학과 정보입니다."
        static var invalidDepartment: String {
            Localization.localized("auth.invalidDepartment", fallback: "유효하지 않은 학과 정보입니다.")
        }

        /// SetNickNameVC - "정보 업데이트 중 오류가 발생했습니다."
        static var updateError: String {
            Localization.localized("auth.updateError", fallback: "정보 업데이트 중 오류가 발생했습니다.")
        }
        
        /// SetNickNameVC - "내 정보가 수정되었어요."
        static var updateSuccess: String {
            Localization.localized("auth.updateSuccess", fallback: "내 정보가 수정되었어요.")
        }

        /// NIcknameTextFieldResultType - "필수 입력 사항입니다"
        static var requiredInput: String {
            Localization.localized("auth.requiredInput", fallback: "필수 입력 사항입니다")
        }
        
        /// NIcknameTextFieldResultType - "중복 확인을 진행해주세요."
        static var needCheckDuplicate: String {
            Localization.localized("auth.needCheckDuplicate", fallback: "중복 확인을 진행해주세요.")
        }

        /// NIcknameTextFieldResultType - "이미 사용 중인 닉네임이에요."
        static var duplicatedNickname: String {
            Localization.localized("auth.duplicatedNickname", fallback: "이미 사용 중인 닉네임이에요.")
        }
        
        /// NIcknameTextFieldResultType - "사용가능한 닉네임이에요"
        static var availableNickname: String {
            Localization.localized("auth.availableNickname", fallback: "사용가능한 닉네임이에요")
        }
        
        /// NIcknameTextFieldResultType - "2~16글자를 입력해 주세요."
        static var nicknameLength: String {
            Localization.localized("auth.nicknameLength", fallback: "2~16글자를 입력해 주세요.")
        }

        /// NIcknameTextFieldResultType - "특수문자로 시작/끝나는 닉네임은 사용할 수 없어요."
        static var specialCharNickname: String {
            Localization.localized("auth.specialCharNickname", fallback: "특수문자로 시작/끝나는 닉네임은 사용할 수 없어요.")
        }

        /// NIcknameTextFieldResultType - "연속된 특수문자(--, __)는 사용할 수 없어요."
        static var continuousSpecialChar: String {
            Localization.localized("auth.continuousSpecialChar", fallback: "연속된 특수문자(--, __)는 사용할 수 없어요.")
        }
        
        /// NIcknameTextFieldResultType - "숫자만으로 된 닉네임은 사용할 수 없어요."
        static var numberOnlyNickname: String {
            Localization.localized("auth.numberOnlyNickname", fallback: "숫자만으로 된 닉네임은 사용할 수 없어요.")
        }

        /// NIcknameTextFieldResultType - "허용 문자(한글/영문/숫자)만 사용할 수 있어요."
        static var allowedChar: String {
            Localization.localized("auth.allowedChar", fallback: "허용 문자(한글/영문/숫자)만 사용할 수 있어요.")
        }
        
        /// NIcknameTextFieldResultType - "사용할 수 없는 단어가 포함되어 있어요."
        static var bannedWord: String {
            Localization.localized("auth.bannedWord", fallback: "사용할 수 없는 단어가 포함되어 있어요.")
        }
        
        /// NIcknameTextFieldResultType - "띄어쓰기로 시작/끝나는 닉네임은 사용할 수 없어요."
        static var spaceNickname: String {
            Localization.localized("auth.spaceNickname", fallback: "띄어쓰기로 시작/끝나는 닉네임은 사용할 수 없어요.")
        }
        
        /// NIcknameTextFieldResultType - "연속된 띄어쓰기는 사용할 수 없어요."
        static var continuousSpace: String {
            Localization.localized("auth.continuousSpace", fallback: "연속된 띄어쓰기는 사용할 수 없어요.")
        }

        /// NIcknameTextFieldResultType - "이모지, 특수문자는 사용할 수 없어요."
        static var emojiSpecialChar: String {
            Localization.localized("auth.emojiSpecialChar", fallback: "이모지, 특수문자는 사용할 수 없어요.")
        }

        /// NIcknameTextFieldResultType - "관리자로 혼동될 수 있는 닉네임은 사용할 수 없어요."
        static var adminNickname: String {
            Localization.localized("auth.adminNickname", fallback: "관리자로 혼동될 수 있는 닉네임은 사용할 수 없어요.")
        }

        /// NIcknameTextFieldResultType - "서비스명 단독 닉네임은 사용할 수 없어요."
        static var serviceNameNickname: String {
            Localization.localized("auth.serviceNameNickname", fallback: "서비스명 단독 닉네임은 사용할 수 없어요.")
        }
        
        /// NIcknameTextFieldResultType - "욕설, 비속어 등의 표현이 포함된 닉네임은 사용할 수 없어요."
        static var slangNickname: String {
            Localization.localized("auth.slangNickname", fallback: "욕설, 비속어 등의 표현이 포함된 닉네임은 사용할 수 없어요.")
        }
    }

    // MARK: - Home
    
    enum Home {
        /// Home - "오늘의 메뉴"
        static var todayMenu: String {
            Localization.localized("home.todayMenu", fallback: "오늘의 메뉴")
        }

        /// Home - "가격"
        static var price: String {
            Localization.localized("home.price", fallback: "가격")
        }

        /// Home - "평점"
        static var rating: String {
            Localization.localized("home.rating", fallback: "평점")
        }

        /// Home - "  -"
        static var emptyRating: String {
            Localization.localized("home.emptyRating", fallback: "  -")
        }

        /// Home - "제공되는 메뉴가 없습니다"
        static var noMenuProvidedMessage: String {
            Localization.localized("home.noMenuProvidedMessage", fallback: "제공되는 메뉴가 없습니다")
        }
        
        /// CustomTimeTabController - "아침"
        static var morning: String {
            Localization.localized("home.morning", fallback: "아침")
        }
        
        /// CustomTimeTabController - "점심"
        static var lunch: String {
            Localization.localized("home.lunch", fallback: "점심")
        }
        
        /// CustomTimeTabController - "저녁"
        static var dinner: String {
            Localization.localized("home.dinner", fallback: "저녁")
        }
        
        /// RestaurantInfoView - "학생 식당"
        static var studentRestaurant: String {
            Localization.localized("home.studentRestaurant", fallback: "학생 식당")
        }

        /// RestaurantInfoView - "식당 위치"
        static var restaurantLocation: String {
            Localization.localized("home.restaurantLocation", fallback: "식당 위치")
        }

        /// RestaurantInfoView - "식당 사진"
        static var restaurantPicture: String {
            Localization.localized("home.restaurantPicture", fallback: "식당 사진")
        }
        
        /// RestaurantInfoView - "숭실대학교"
        static var soongsilUniversity: String {
            Localization.localized("home.soongsilUniversity", fallback: "숭실대학교")
        }

        /// RestaurantInfoView - "영업 시간"
        static var businessHour: String {
            Localization.localized("home.businessHour", fallback: "영업 시간")
        }

        /// RestaurantInfoView - "비고"
        static var note: String {
            Localization.localized("home.note", fallback: "비고")
        }
        
        /// RestaurantInfoView - "아시안푸드, 돈까스, 샐러드, 국밥 등\n카페"
        static var dodamEtc: String {
            Localization.localized("home.dodamEtc", fallback: "아시안푸드, 돈까스, 샐러드, 국밥 등\n카페")
        }
        
        /// RestaurantMenuGroupCell - "영업 시간이 아니에요."
        static var notBusinessHour: String {
            Localization.localized("home.notBusinessHour", fallback: "영업 시간이 아니에요.")
        }

        /// RestaurantTableViewHeader - "기숙사 식당"
        static var dormitoryRestaurant: String {
            Localization.localized("home.dormitoryRestaurant", fallback: "기숙사 식당")
        }
    }

    // MARK: - Map
    
    enum Map {
        /// MainMapVC - "제휴 지도"
        static var map: String {
            Localization.localized("map.map", fallback: "제휴 지도")
        }

        /// MainMapView - "전체"
        static var all: String {
            Localization.localized("map.all", fallback: "전체")
        }

        /// MainMapView - "내 제휴"
        static var myPartner: String {
            Localization.localized("map.myPartner", fallback: "내 제휴")
        }

        /// NoDepartmentSheetVC - "학과를 입력하고\n나만의 제휴를 확인해보세요!"
        static var inputDepartment: String {
            Localization.localized("map.inputDepartment", fallback: "학과를 입력하고\n나만의 제휴를 확인해보세요!")
        }
        
        /// NoDepartmentSheetVC - "학과 입력하기"
        static var inputDepartmentButton: String {
            Localization.localized("map.inputDepartmentButton", fallback: "학과 입력하기")
        }

        /// PartnershipDetailSheetVC - "음식점"
        static var restaurant: String {
            Localization.localized("map.restaurant", fallback: "음식점")
        }

        /// PartnershipDetailSheetVC - "카페"
        static var cafe: String {
            Localization.localized("map.cafe", fallback: "카페")
        }

        /// PartnershipDetailSheetVC - "주점"
        static var pub: String {
            Localization.localized("map.pub", fallback: "주점")
        }

        /// PartnershipDetailSheetVC - "학과 정보 없음"
        static var noDepartmentInfo: String {
            Localization.localized("map.noDepartmentInfo", fallback: "학과 정보 없음")
        }

        /// MainMapVC+Location - "위치 권한 필요"
        static var needLocationAuth: String {
            Localization.localized("map.needLocationAuth", fallback: "위치 권한 필요")
        }
        
        /// MainMapVC+Location - "지도에서 내 위치를 바로 확인하고, 현재 위치 주변의 제휴점들을 손쉽게 찾아볼 수 있도록 위치 권한을 허용해 주세요."
        static var locationAuthDescription: String {
            Localization.localized(
                "map.locationAuthDescription",
                fallback: "지도에서 내 위치를 바로 확인하고, 현재 위치 주변의 제휴점들을 손쉽게 찾아볼 수 있도록 위치 권한을 허용해 주세요."
            )
        }
    }

    // MARK: - MyPage
    
    enum MyPage {
        /// "마이페이지"
        static var myPage: String {
            Localization.localized("myPage.myPage", fallback: "마이페이지")
        }

        /// UserWithdrawVC - "회원탈퇴"
        static var withdraw: String {
            Localization.localized("myPage.withdraw", fallback: "회원탈퇴")
        }

        /// MyPageVC - "EAT-SSU 수신 동의"
        static func agreeNoti(date: String) -> String {
            return Localization.formatted("myPage.agreeNoti", fallback: "EAT-SSU 수신 동의 (%@)", date)
        }
        
        /// MyPageVC - "EAT-SSU 수신 거절"
        static func disagreeNoti(date: String) -> String {
            return Localization.formatted("myPage.disagreeNoti", fallback: "EAT-SSU 수신 거절 (%@)", date)
        }
        
        // MARK: - MyPageSection: 알림 및 활동

        /// MyPageSectionVC - "알림 및 활동"
        static var activitySection: String {
            Localization.localized("myPage.activitySection", fallback: "알림 및 활동")
        }
        
        /// "내 정보"
        static var myInfo: String {
            Localization.localized("myPage.myInfo", fallback: "내 정보")
        }

        /// "내 리뷰"
        static var myReview: String {
            Localization.localized("myPage.myReview", fallback: "내 리뷰")
        }
        
        /// NotificationSettingTableViewCell - "푸시 알림 설정"
        static var pushNotificationSetting: String {
            Localization.localized("myPage.pushNotificationSetting", fallback: "푸시 알림 설정")
        }
        
        /// Push Notification key for UserDefaults
        static let pushNotificationUserSettingKey: String = "pushNotificationUserSettingKey"

        /// NotificationSettingTableViewCell - "매일 오전 11시에 알림을 보내드려요"
        static var pushNotificationDescription: String {
            Localization.localized("myPage.pushNotificationDescription", fallback: "매일 오전 11시에 알림을 보내드려요")
        }
        
        /// MyPageVC - "알림 설정 중 오류가 발생했습니다."
        static var notiSettingError: String {
            Localization.localized("myPage.notiSettingError", fallback: "알림 설정 중 오류가 발생했습니다.")
        }
        
        // MARK: - MyPageSection: 서비스 정보

        /// MyPageSectionVC - "서비스 정보"
        static var serviceInfoSection: String {
            Localization.localized("myPage.serviceInfoSection", fallback: "서비스 정보")
        }
        
        /// MyPageVC - "문의하기"
        static var inquiry: String {
            Localization.localized("myPage.inquiry", fallback: "문의하기")
        }
        
        /// CreatorVC - "만든 사람들"
        static var creators: String {
            Localization.localized("myPage.creators", fallback: "만든 사람들")
        }
        
        /// MyPageVC - "EAT-SSU 인스타그램"
        static var instagram: String {
            Localization.localized("myPage.instagram", fallback: "EAT-SSU 인스타그램")
        }
        
        // MARK: - MyPageSection: 기타

        /// MyPageSectionVC - "기타"
        static var etcSection: String {
            Localization.localized("myPage.etcSection", fallback: "기타")
        }
        
        /// MyPageVC - "언어 설정"
        static var languageSetting: String {
            Localization.localized("myPage.languageSetting", fallback: "언어 설정")
        }
        
        /// MyPageVC - "현재 언어"
        static var currentLanguage: String {
            return AppLanguageManager.shared.currentLanguage.title
        }
        
        /// MyPageVC - "약관 및 정책"
        static var termsAndPolicy: String {
            Localization.localized("myPage.termsAndPolicy", fallback: "약관 및 정책")
        }

        /// MyPageVC - "서비스 이용약관"
        static var termsOfUse: String {
            Localization.localized("myPage.termsOfUse", fallback: "서비스 이용약관")
        }

        /// MyPageVC - "개인정보처리방침"
        static var privacyTermsOfUse: String {
            Localization.localized("myPage.privacyTermsOfUse", fallback: "개인정보처리방침")
        }
        
        /// MyPageVC - "로그아웃"
        static var logout: String {
            Localization.localized("myPage.logout", fallback: "로그아웃")
        }
        
        /// MyPageVC - "정말 로그아웃 하시겠습니까?"
        static var askLogout: String {
            Localization.localized("myPage.askLogout", fallback: "정말 로그아웃 하시겠습니까?")
        }

        /// MyReviewVC - "리뷰 수정 혹은 삭제"
        static var fixOrDeleteReview: String {
            Localization.localized("myPage.fixOrDeleteReview", fallback: "리뷰 수정 혹은 삭제")
        }
        
        /// MyReviewVC - "작성하신 리뷰를 수정 또는 삭제하시겠습니까?"
        static var askFixOrDeleteReview: String {
            Localization.localized("myPage.askFixOrDeleteReview", fallback: "작성하신 리뷰를 수정 또는 삭제하시겠습니까?")
        }
        
        /// MyReviewVC - "리뷰 삭제하기"
        static var deleteMyReview: String {
            Localization.localized("myPage.deleteMyReview", fallback: "리뷰 삭제하기")
        }
        
        /// MyReviewVC - "해당 리뷰를 삭제할까요?"
        static var askDeleteMyReview: String {
            Localization.localized("myPage.askDeleteMyReview", fallback: "해당 리뷰를 삭제할까요?")
        }
        
        /// MyReviewVC - "리뷰가 성공적으로 삭제되었습니다."
        static var deleteMyReviewSuccess: String {
            Localization.localized("myPage.deleteMyReviewSuccess", fallback: "리뷰가 성공적으로 삭제되었습니다.")
        }
        
        /// MyPageView - "다시 시도해주세요"
        static var retry: String {
            Localization.localized("myPage.retry", fallback: "다시 시도해주세요")
        }
        
        /// MyPageView - "앱 버전"
        static var appVersion: String {
            Localization.localized("myPage.appVersion", fallback: "앱 버전")
        }
        
        /// MyPageView - "탈퇴하기"
        static var withdrawButton: String {
            Localization.localized("myPage.withdrawButton", fallback: "탈퇴하기")
        }

        /// MyPageView - "알 수 없음"
        static var unknownUser: String {
            Localization.localized("myPage.unknownUser", fallback: "알 수 없음")
        }

        /// ProvisionVC - "이용약관"
        static var defaultTerms: String {
            Localization.localized("myPage.defaultTerms", fallback: "이용약관")
        }
        
        /// UserWithdrawView - "정말 탈퇴하시겠습니까?"
        static var confirmWithdrawal: String {
            Localization.localized("myPage.confirmWithdrawal", fallback: "정말 탈퇴하시겠습니까?")
        }

        /// UserWithdrawView - "작성한 리뷰 게시글은 삭제되지 않으며, (알수없음)으로 표시됩니다.\n자세한 내용은 서비스이용약관 및 개인정보처리방침을 확인해 주세요."
        static var withdrawalNotice: String {
            Localization.localized(
                "myPage.withdrawalNotice",
                fallback: "작성한 리뷰 게시글은 삭제되지 않으며, (알수없음)으로 표시됩니다.\n자세한 내용은 서비스이용약관 및 개인정보처리방침을 확인해 주세요."
            )
        }

        /// UserWithdrawView - "올바른 입력입니다."
        static var validInputMessage: String {
            Localization.localized("myPage.validInputMessage", fallback: "올바른 입력입니다")
        }

        /// UserWithdrawView - "올바르지 않은 닉네임입니다"
        static var invalidNicknameMessage: String {
            Localization.localized("myPage.invalidNicknameMessage", fallback: "올바르지 않은 닉네임입니다")
        }
    }
    
    // MARK: - Review
    
    enum Review {
        /// ReportVC - "EAT SSU 팀에게 보내기"
        static var sendToTeam: String {
            Localization.localized("review.sendToTeam", fallback: "EAT SSU 팀에게 보내기")
        }
        
        /// ReportVC - "신고하기"
        static var report: String {
            Localization.localized("review.report", fallback: "신고하기")
        }
        
        /// ReportVC - "사유를 선택해주세요!"
        static var selectReason: String {
            Localization.localized("review.selectReason", fallback: "사유를 선택해주세요!")
        }
        
        /// ReportVC - "신고가 성공적으로 접수되었어요!"
        static var reportSuccess: String {
            Localization.localized("review.reportSuccess", fallback: "신고가 성공적으로 접수되었어요!")
        }
        
        /// ReportVC, ReportView - "메뉴와 관련없는 내용"
        static var unrelatedMenu: String {
            Localization.localized("review.unrelatedMenu", fallback: "메뉴와 관련없는 내용")
        }
        
        /// ReportVC, ReportView - "음란성, 욕설 등 부적절한 내용"
        static var inappropriateContent: String {
            Localization.localized("review.inappropriateContent", fallback: "음란성, 욕설 등 부적절한 내용")
        }
        
        /// ReportVC, ReportView - "부적절한 홍보 또는 광고"
        static var inappropriateAd: String {
            Localization.localized("review.inappropriateAd", fallback: "부적절한 홍보 또는 광고")
        }
        
        /// ReportVC, ReportView - "리뷰 작성 취지에 맞지 않는 내용 (복사글 등)"
        static var notReviewFormat: String {
            Localization.localized("review.notReviewFormat", fallback: "리뷰 작성 취지에 맞지 않는 내용 (복사글 등)")
        }
        
        /// ReportVC, ReportView - "저작권 도용 의심 (사진 등)"
        static var copyright: String {
            Localization.localized("review.copyright", fallback: "저작권 도용 의심 (사진 등)")
        }
        
        /// ReportVC, ReportView - "기타 (하단 내용 작성)"
        static var etc: String {
            Localization.localized("review.etc", fallback: "기타 (하단 내용 작성)")
        }
        
        /// ReportView - "리뷰 신고 사유를 알려주세요"
        static var reportReason: String {
            Localization.localized("review.reportReason", fallback: "리뷰 신고 사유를 알려주세요")
        }
        
        /// ReportView - "하나의 리뷰에 대해 24시간 내 한 번만 신고 가능합니다."
        static var reportGuide: String {
            Localization.localized("review.reportGuide", fallback: "하나의 리뷰에 대해 24시간 내 한 번만 신고 가능합니다.")
        }
        
        /// ReportView - "리뷰 신고 사유를 작성해 주세요"
        static var inputReportReason: String {
            Localization.localized("review.inputReportReason", fallback: "리뷰 신고 사유를 작성해 주세요")
        }
        
        /// ReviewVC - "리뷰 작성하기"
        static var writeReview: String {
            Localization.localized("review.writeReview", fallback: "리뷰 작성하기")
        }
        
        /// ReviewVC - "리뷰가 성공적으로 등록되었습니다."
        static var registerReviewSuccess: String {
            Localization.localized("review.registerReviewSuccess", fallback: "리뷰가 성공적으로 등록되었습니다.")
        }
        
        /// ReviewVC - "리뷰"
        static var review: String {
            Localization.localized("review.review", fallback: "리뷰")
        }

        /// ReviewVC - "리뷰 삭제"
        static var deleteReview: String {
            Localization.localized("review.deleteReview", fallback: "리뷰 삭제")
        }
        
        /// ReviewVC - "해당 리뷰를 삭제할까요?"
        static var askDeleteReview: String {
            Localization.localized("review.askDeleteReview", fallback: "해당 리뷰를 삭제할까요?")
        }

        /// ReviewVC - "리뷰 신고하기"
        static var reportReview: String {
            Localization.localized("review.reportReview", fallback: "리뷰 신고하기")
        }
        
        /// ReviewVC - "해당 리뷰를 신고하시겠습니까?"
        static var askReportReview: String {
            Localization.localized("review.askReportReview", fallback: "해당 리뷰를 신고하시겠습니까?")
        }

        /// ReviewVC - "리뷰가 성공적으로 삭제되었습니다."
        static var deleteReviewSuccess: String {
            Localization.localized("review.deleteReviewSuccess", fallback: "리뷰가 성공적으로 삭제되었습니다.")
        }
        
        /// ReviewVC - "리뷰 삭제에 실패했습니다."
        static var deleteReviewFail: String {
            Localization.localized("review.deleteReviewFail", fallback: "리뷰 삭제에 실패했습니다.")
        }
        
        /// SetRateVC - "리뷰 수정하기"
        static var fixReview: String {
            Localization.localized("review.fixReview", fallback: "리뷰 수정하기")
        }
        
        /// SetRateVC - "리뷰 남기기"
        static var leaveReview: String {
            Localization.localized("review.leaveReview", fallback: "리뷰 남기기")
        }

        /// 메뉴 이름의 받침 유무에 따라 '을/를'을 동적으로 붙여 추천 문장을 생성합니다.
        static func recommendMenu(name: String) -> String {
            guard let lastChar = name.last,
                  let lastScalar = lastChar.unicodeScalars.first else {
                return Localization.formatted("review.recommendMenu.default", fallback: "%@을(를) 추천하시겠어요?", name)
            }
            
            let hangulStart: UInt32 = 0xAC00
            let hangulEnd: UInt32 = 0xD7A3
            
            if lastScalar.value >= hangulStart && lastScalar.value <= hangulEnd {
                let hasJongseong = (lastScalar.value - hangulStart) % 28 != 0
                if hasJongseong {
                    return Localization.formatted("review.recommendMenu.withJongseong", fallback: "%@을 추천하시겠어요?", name)
                }
            }
            
            return Localization.formatted("review.recommendMenu.withoutJongseong", fallback: "%@를 추천하시겠어요?", name)
        }
        
        /// SetRateVC - "메뉴를 추천하시겠어요?"
        static var recommendMenuTitle: String {
            Localization.localized("review.recommendMenuTitle", fallback: "메뉴를 추천하시겠어요?")
        }
        
        /// SetRateVC - "리뷰 수정 완료하기"
        static var fixReviewComplete: String {
            Localization.localized("review.fixReviewComplete", fallback: "리뷰 수정 완료하기")
        }

        /// SetRateVC - "완료하기"
        static var complete: String {
            Localization.localized("review.complete", fallback: "완료하기")
        }
        
        /// SetRateVC - "별점을 입력해주세요!"
        static var inputRating: String {
            Localization.localized("review.inputRating", fallback: "별점을 입력해주세요!")
        }
        
        /// SetRateVC - "메뉴 목록 조회에 실패했습니다."
        static var loadMenuListFail: String {
            Localization.localized("review.loadMenuListFail", fallback: "메뉴 목록 조회에 실패했습니다.")
        }
        
        /// SetRateVC - "수정할 리뷰 정보가 없습니다."
        static var noReviewInfoForFix: String {
            Localization.localized("review.noReviewInfoForFix", fallback: "수정할 리뷰 정보가 없습니다.")
        }

        /// SetRateVC - "리뷰가 성공적으로 수정되었습니다."
        static var fixReviewSuccess: String {
            Localization.localized("review.fixReviewSuccess", fallback: "리뷰가 성공적으로 수정되었습니다.")
        }
        
        /// SetRateVC - "리뷰 수정에 실패했습니다."
        static var fixReviewFail: String {
            Localization.localized("review.fixReviewFail", fallback: "리뷰 수정에 실패했습니다.")
        }
        
        /// SetRateVC - "식단 정보가 없습니다."
        static var noMealInfo: String {
            Localization.localized("review.noMealInfo", fallback: "식단 정보가 없습니다.")
        }
        
        /// SetRateVC - "리뷰 업로드에 실패했습니다."
        static var uploadReviewFail: String {
            Localization.localized("review.uploadReviewFail", fallback: "리뷰 업로드에 실패했습니다.")
        }
        
        /// SetRateVC - "메뉴 정보가 없습니다."
        static var noMenuInfo: String {
            Localization.localized("review.noMenuInfo", fallback: "메뉴 정보가 없습니다.")
        }
        
        /// SetRateVC - "메뉴에 대한 상세한 리뷰를 작성해주세요"
        static var inputDetailReview: String {
            Localization.localized("review.inputDetailReview", fallback: "메뉴에 대한 상세한 리뷰를 작성해주세요")
        }
        
        /// SetRateVC - "나가시겠어요?"
        static var askLeave: String {
            Localization.localized("review.askLeave", fallback: "나가시겠어요?")
        }

        /// SetRateVC - "지금 나가면 작성한 내용이 저장되지 않습니다."
        static var leaveWarning: String {
            Localization.localized("review.leaveWarning", fallback: "지금 나가면 작성한 내용이 저장되지 않습니다.")
        }

        /// SetRateVC - "나가기"
        static var leave: String {
            Localization.localized("review.leave", fallback: "나가기")
        }
        
        /// SetRateVC - "계속 작성"
        static var continueWriting: String {
            Localization.localized("review.continueWriting", fallback: "계속 작성")
        }
        
        /// ReviewEmptyViewCell - "아직 작성된 리뷰가 없어요!"
        static var noReview: String {
            Localization.localized("review.noReview", fallback: "아직 작성된 리뷰가 없어요!")
        }

        /// ReviewEmptyViewCell - "메뉴에 가장 먼저 리뷰를 남겨주세요!"
        static var beFirstReviewer: String {
            Localization.localized("review.beFirstReviewer", fallback: "메뉴에 가장 먼저 리뷰를 남겨주세요!")
        }
        
        /// ReviewEmptyViewCell - "로그인이 필요합니다"
        static var needLogin: String {
            Localization.localized("review.needLogin", fallback: "로그인이 필요합니다")
        }
        
        /// ReviewEmptyViewCell - "로그인 후 리뷰를 확인하세요"
        static var checkReviewAfterLogin: String {
            Localization.localized("review.checkReviewAfterLogin", fallback: "로그인 후 리뷰를 확인하세요")
        }
        
        /// ReviewEmptyViewCell - "아직 작성한 리뷰가 없어요"
        static var noWrittenReview: String {
            Localization.localized("review.noWrittenReview", fallback: "아직 작성한 리뷰가 없어요")
        }
        
        /// ReviewEmptyViewCell - "첫 리뷰를 남겨 주세요!"
        static var writeFirstReview: String {
            Localization.localized("review.writeFirstReview", fallback: "첫 리뷰를 남겨 주세요!")
        }

        /// ReviewDividerCell - "리뷰"
        static func reviewCount(_ count: Int) -> String {
            return Localization.formatted("review.reviewCount", fallback: "리뷰 %d", count)
        }
        
        /// ReviewRateViewCell - "오늘의 메뉴"
        static var todayMenu: String {
            Localization.localized("review.todayMenu", fallback: "오늘의 메뉴")
        }

        /// ReviewRateViewCell - "5점"
        static var fiveStars: String {
            Localization.localized("review.fiveStars", fallback: "5점")
        }

        /// ReviewRateViewCell - "4점"
        static var fourStars: String {
            Localization.localized("review.fourStars", fallback: "4점")
        }

        /// ReviewRateViewCell - "3점"
        static var threeStars: String {
            Localization.localized("review.threeStars", fallback: "3점")
        }

        /// ReviewRateViewCell - "2점"
        static var twoStars: String {
            Localization.localized("review.twoStars", fallback: "2점")
        }

        /// ReviewRateViewCell - "1점"
        static var oneStar: String {
            Localization.localized("review.oneStar", fallback: "1점")
        }

        /// SetRateView - "오늘의 식사는 어떠셨나요?"
        static var rateTodayMeal: String {
            Localization.localized("review.rateTodayMeal", fallback: "오늘의 식사는 어떠셨나요?")
        }

        /// SetRateView - "추천하고 싶은 메뉴가 있나요?"
        static var recommendMenu: String {
            Localization.localized("review.recommendMenu", fallback: "추천하고 싶은 메뉴가 있나요?")
        }
        
        /// SetRateView - "사진 추가 (0/1)"
        static func addPhoto(count: Int) -> String {
            return Localization.formatted("review.addPhoto", fallback: "사진 추가 (%d/1)", count)
        }

        /// character count
        static func characterCount(current: Int, max: Int) -> String {
            return Localization.formatted("review.characterCount", fallback: "%d / %d", current, max)
        }
    }
    
    // MARK: - Coffee

    enum Coffee {
        /// "나가시겠어요?"
        static var askLeave: String {
            Localization.localized("coffee.askLeave", fallback: "나가시겠어요?")
        }

        /// "지금 나가면 진행 상황이\n저장되지 않습니다."
        static var leaveWarning: String {
            Localization.localized("coffee.leaveWarning", fallback: "지금 나가면 진행 상황이\n저장되지 않습니다.")
        }

        /// "나가기"
        static var leave: String {
            Localization.localized("coffee.leave", fallback: "나가기")
        }

        /// "계속하기"
        static var continueEvent: String {
            Localization.localized("coffee.continueEvent", fallback: "계속하기")
        }
    }

    // MARK: - Splash
    
    enum Splash {
        /// NoticeSplashVC - "긴급 서버 점검 안내"
        static var serverInspection: String {
            Localization.localized("splash.serverInspection", fallback: "긴급 서버 점검 안내")
        }
    }
    
    // MARK: - PromotionPopup
    
    enum PromotionPopup {
        /// 03. 16(월)~03. 27(금)
        static var period: String {
            Localization.localized("promotionPopup.period", fallback: "03. 16(월)~03. 27(금)")
        }
        
        /// EAT-SSU 인스타그램 바로가기
        static var instagramButtonTitle: String {
            Localization.localized("promotionPopup.instagramButtonTitle", fallback: "EAT-SSU 인스타그램 바로가기")
        }
        
        /// 자세한 내용은 EAT-SSU 인스타그램을 확인해 주세요
        static var guideMessage: String {
            Localization.localized("promotionPopup.guideMessage", fallback: "자세한 내용은 EAT-SSU 인스타그램을 확인해 주세요")
        }
        
        /// 다시 보지 않기
        static var neverShowAgain: String {
            Localization.localized("promotionPopup.neverShowAgain", fallback: "다시 보지 않기")
        }
        
        /// 닫기
        static var close: String {
            Localization.localized("promotionPopup.close", fallback: "닫기")
        }
    }

    // MARK: - Notification
    
    enum Notification {
        /// 🤔 오늘 밥 뭐 먹지…
        static var dailyWeekdayNotificationTitle: String {
            Localization.localized("notification.dailyWeekdayNotificationTitle", fallback: "🤔 오늘 밥 뭐 먹지…")
        }

        /// 오늘의 학식을 확인해보세요!
        static var dailyWeekdayNotificationBody: String {
            Localization.localized("notification.dailyWeekdayNotificationBody", fallback: "오늘의 학식을 확인해보세요!")
        }
        /// 알림 권한 필요
        static var permissionDeniedMessage: String {
            Localization.localized(
                "notification_error_permission_denied_message",
                fallback: "알림 권한 필요"
            )
        }
        /// 알림을 받으려면 설정에서 알림 권한을 허용해주세요.
        static var permissionDeniedDescription: String {
            Localization.localized(
                "notification_error_permission_denied_description",
                fallback: "알림을 받으려면 설정에서 알림 권한을 허용해주세요."
            )
        }
        /// 알 수 없는 오류
        static var unknownErrorMessage: String {
            Localization.localized(
                "notification_error_unknown_message",
                fallback: "알 수 없는 오류"
            )
        }
        /// 다시 시도해주세요.
        static var unknownErrorDescription: String {
            Localization.localized(
                "notification_error_unknown_description",
                fallback: "다시 시도해주세요."
            )
        }
    }
    
    // MARK: - Restaurant
    
    enum Restaurant {
        /// "기숙사 식당"
        static var dormitoryRestaurant: String {
            Localization.localized("restaurant.dormitoryRestaurant", fallback: "기숙사 식당")
        }

        /// "도담 식당"
        static var dodamRestaurant: String {
            Localization.localized("restaurant.dodamRestaurant", fallback: "도담 식당")
        }

        /// "학생 식당"
        static var studentRestaurant: String {
            Localization.localized("restaurant.studentRestaurant", fallback: "학생 식당")
        }

        /// "스낵 코너"
        static var snackCorner: String {
            Localization.localized("restaurant.snackCorner", fallback: "스낵 코너")
        }

        /// "FACULTY (교직원 전용)"
        static var facultyRestaurant: String {
            Localization.localized("restaurant.facultyRestaurant", fallback: "FACULTY (교직원 전용)")
        }
    }
}
