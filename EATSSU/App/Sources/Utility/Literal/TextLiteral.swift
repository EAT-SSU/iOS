//
//  TextLiteral.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/06/27.
//

import Foundation

enum TextLiteral {
    
    // MARK: - KakaoChannel
    enum KakaoChannel {
        /// EATSSU 카카오 채널 ID
        static let id: String = "_ZlVAn"
    }

    // MARK: - Common
    
    enum Common {
        /// "확인"
        static let confirm: String = "확인"
        
        /// "취소"
        static let cancel: String = "취소"
        
        /// "취소하기"
        static let cancelDark: String = "취소하기"
        
        /// "삭제하기"
        static let delete: String = "삭제하기"
        
        /// "수정하기"
        static let fix: String = "수정하기"

        /// "로그인이 필요한 서비스입니다"
        static let needLogin: String = "로그인이 필요한 서비스입니다"
        
        /// "로그인 하시겠습니까?"
        static let askLogin: String = "로그인 하시겠습니까?"
        
        /// "설정으로 이동"
        static let moveToSetting: String = "설정으로 이동"
        
        /// "탈퇴 처리가 완료되었습니다."
        static let withdrawComplete: String = "탈퇴 처리가 완료되었습니다."
        
        /// "잠시 후 다시 시도해주세요."
        static let tryAgain: String = "잠시 후 다시 시도해주세요."
        
        /// "세션이 만료되었습니다. 다시 로그인해주세요."
        static let sessionExpired: String = "세션이 만료되었습니다. 다시 로그인해주세요."

        /// "에러가 발생했습니다"
        static let errorOccured: String = "에러가 발생했습니다"
        
        /// "다시 시도하세요"
        static let retry: String = "다시 시도하세요"
    }
    
    // MARK: - TabBar
    
    enum TabBar {
        /// "학식"
        static let meal: String = "학식"
        
        /// "지도"
        static let map: String = "지도"
        
        /// "나만아니면돼~"
        static let coffee: String = "나만아니면돼~"

        /// "마이"
        static let my: String = "마이"
    }

    // MARK: - Auth
    
    enum Auth {
        /// "닉네임을 입력해주세요"
        static let inputNickName: String = "닉네임을 입력해주세요"

        /// "Apple로 로그인"
        static let signInWithApple: String = "Apple로 로그인"
        
        /// "카카오 로그인"
        static let signInWithKakao: String = "카카오 로그인"

        /// "둘러보기"
        static let lookingWithNoSignIn: String = "둘러보기"

        /// LoginVC - "카카오톡으로 생성된 계정입니다."
        static let kakaoAccount: String = "카카오톡으로 생성된 계정입니다."

        /// LoginVC - "Apple로 생성된 계정입니다."
        static let appleAccount: String = "Apple로 생성된 계정입니다."

        /// SetNickNameView - "닉네임 설정"
        static let setNickname: String = "닉네임 설정"

        /// SetNickNameView - "중복 확인"
        static let checkDuplicate: String = "중복 확인"
        
        /// SetNickNameView - "소속 설정"
        static let setCollege: String = "소속 설정"

        /// SetNickNameView - "단과대"
        static let college: String = "단과대"

        /// SetNickNameView - "학과"
        static let department: String = "학과"
        
        /// SetNickNameView - "연결된 계정"
        static let linkedAccount: String = "연결된 계정"

        /// SetNickNameView - "없음"
        static let empty: String = "없음"
        
        /// SetNickNameView - "저장하기"
        static let save: String = "저장하기"

        /// SetNickNameView - "카카오"
        static let kakao: String = "카카오"

        /// SetNickNameView - "APPLE"
        static let apple: String = "APPLE"
        
        /// SetNickNameVC - "변경된 정보가 없습니다."
        static let noChanges: String = "변경된 정보가 없습니다."
        
        /// SetNickNameVC - "유효하지 않은 학과 정보입니다."
        static let invalidDepartment: String = "유효하지 않은 학과 정보입니다."

        /// SetNickNameVC - "정보 업데이트 중 오류가 발생했습니다."
        static let updateError: String = "정보 업데이트 중 오류가 발생했습니다."
        
        /// SetNickNameVC - "내 정보가 수정되었어요."
        static let updateSuccess: String = "내 정보가 수정되었어요."

        /// NIcknameTextFieldResultType - "필수 입력 사항입니다"
        static let requiredInput: String = "필수 입력 사항입니다"
        
        /// NIcknameTextFieldResultType - "중복 확인을 진행해주세요."
        static let needCheckDuplicate: String = "중복 확인을 진행해주세요."

        /// NIcknameTextFieldResultType - "이미 사용 중인 닉네임이에요."
        static let duplicatedNickname: String = "이미 사용 중인 닉네임이에요."
        
        /// NIcknameTextFieldResultType - "사용가능한 닉네임이에요"
        static let availableNickname: String = "사용가능한 닉네임이에요"
        
        /// NIcknameTextFieldResultType - "2~16글자를 입력해 주세요."
        static let nicknameLength: String = "2~16글자를 입력해 주세요."

        /// NIcknameTextFieldResultType - "특수문자로 시작/끝나는 닉네임은 사용할 수 없어요."
        static let specialCharNickname: String = "특수문자로 시작/끝나는 닉네임은 사용할 수 없어요."

        /// NIcknameTextFieldResultType - "연속된 특수문자(--, __)는 사용할 수 없어요."
        static let continuousSpecialChar: String = "연속된 특수문자(--, __)는 사용할 수 없어요."
        
        /// NIcknameTextFieldResultType - "숫자만으로 된 닉네임은 사용할 수 없어요."
        static let numberOnlyNickname: String = "숫자만으로 된 닉네임은 사용할 수 없어요."

        /// NIcknameTextFieldResultType - "허용 문자(한글/영문/숫자)만 사용할 수 있어요."
        static let allowedChar: String = "허용 문자(한글/영문/숫자)만 사용할 수 있어요."
        
        /// NIcknameTextFieldResultType - "사용할 수 없는 단어가 포함되어 있어요."
        static let bannedWord: String = "사용할 수 없는 단어가 포함되어 있어요."
        
        /// NIcknameTextFieldResultType - "띄어쓰기로 시작/끝나는 닉네임은 사용할 수 없어요."
        static let spaceNickname: String = "띄어쓰기로 시작/끝나는 닉네임은 사용할 수 없어요."
        
        /// NIcknameTextFieldResultType - "연속된 띄어쓰기는 사용할 수 없어요."
        static let continuousSpace: String = "연속된 띄어쓰기는 사용할 수 없어요."

        /// NIcknameTextFieldResultType - "이모지, 특수문자는 사용할 수 없어요."
        static let emojiSpecialChar: String = "이모지, 특수문자는 사용할 수 없어요."

        /// NIcknameTextFieldResultType - "관리자로 혼동될 수 있는 닉네임은 사용할 수 없어요."
        static let adminNickname: String = "관리자로 혼동될 수 있는 닉네임은 사용할 수 없어요."

        /// NIcknameTextFieldResultType - "서비스명 단독 닉네임은 사용할 수 없어요."
        static let serviceNameNickname: String = "서비스명 단독 닉네임은 사용할 수 없어요."
        
        /// NIcknameTextFieldResultType - "욕설, 비속어 등의 표현이 포함된 닉네임은 사용할 수 없어요."
        static let slangNickname: String = "욕설, 비속어 등의 표현이 포함된 닉네임은 사용할 수 없어요."
    }

    // MARK: - Home
    
    enum Home {
        /// Home - "오늘의 메뉴"
        static let todayMenu: String = "오늘의 메뉴"

        /// Home - "가격"
        static let price: String = "가격"

        /// Home - "평점"
        static let rating: String = "평점"

        /// Home - "  -"
        static let emptyRating: String = "  -"

        /// Home - "제공되는 메뉴가 없습니다"
        static let noMenuProvidedMessage: String = "제공되는 메뉴가 없습니다"
        
        /// CustomTimeTabController - "아침"
        static let morning: String = "아침"
        
        /// CustomTimeTabController - "점심"
        static let lunch: String = "점심"
        
        /// CustomTimeTabController - "저녁"
        static let dinner: String = "저녁"
        
        /// RestaurantInfoView - "학생 식당"
        static let studentRestaurant: String = "학생 식당"

        /// RestaurantInfoView - "식당 위치"
        static let restaurantLocation: String = "식당 위치"

        /// RestaurantInfoView - "식당 사진"
        static let restaurantPicture: String = "식당 사진"
        
        /// RestaurantInfoView - "숭실대학교"
        static let soongsilUniversity: String = "숭실대학교"

        /// RestaurantInfoView - "영업 시간"
        static let businessHour: String = "영업 시간"

        /// RestaurantInfoView - "비고"
        static let note: String = "비고"
        
        /// RestaurantInfoView - "아시안푸드, 돈까스, 샐러드, 국밥 등\n카페"
        static let dodamEtc: String = "아시안푸드, 돈까스, 샐러드, 국밥 등\n카페"
        
        /// RestaurantMenuGroupCell - "영업 시간이 아니에요."
        static let notBusinessHour: String = "영업 시간이 아니에요."

        /// RestaurantTableViewHeader - "기숙사 식당"
        static let dormitoryRestaurant: String = "기숙사 식당"
    }

    // MARK: - Map
    
    enum Map {
        /// MainMapVC - "제휴 지도"
        static let map: String = "제휴 지도"

        /// MainMapView - "전체"
        static let all: String = "전체"

        /// MainMapView - "내 제휴"
        static let myPartner: String = "내 제휴"

        /// NoDepartmentSheetVC - "학과를 입력하고\n나만의 제휴를 확인해보세요!"
        static let inputDepartment: String = "학과를 입력하고\n나만의 제휴를 확인해보세요!"
        
        /// NoDepartmentSheetVC - "학과 입력하기"
        static let inputDepartmentButton: String = "학과 입력하기"

        /// PartnershipDetailSheetVC - "음식점"
        static let restaurant: String = "음식점"

        /// PartnershipDetailSheetVC - "카페"
        static let cafe: String = "카페"

        /// PartnershipDetailSheetVC - "주점"
        static let pub: String = "주점"

        /// PartnershipDetailSheetVC - "학과 정보 없음"
        static let noDepartmentInfo: String = "학과 정보 없음"

        /// MainMapVC+Location - "위치 권한 필요"
        static let needLocationAuth: String = "위치 권한 필요"
        
        /// MainMapVC+Location - "지도에서 내 위치를 바로 확인하고, 현재 위치 주변의 제휴점들을 손쉽게 찾아볼 수 있도록 위치 권한을 허용해 주세요."
        static let locationAuthDescription: String = "지도에서 내 위치를 바로 확인하고, 현재 위치 주변의 제휴점들을 손쉽게 찾아볼 수 있도록 위치 권한을 허용해 주세요."
    }

    // MARK: - MyPage
    
    enum MyPage {
        /// "마이페이지"
        static let myPage: String = "마이페이지"

        /// "내 정보"
        static let myInfo: String = "내 정보"

        /// "내 리뷰"
        static let myReview: String = "내 리뷰"
        
        /// UserWithdrawVC - "회원탈퇴"
        static let withdraw: String = "회원탈퇴"
        
        /// MyPageVC - "로그아웃"
        static let logout: String = "로그아웃"
        
        /// MyPageVC - "정말 로그아웃 하시겠습니까?"
        static let askLogout: String = "정말 로그아웃 하시겠습니까?"
        
        /// MyPageVC - "EAT-SSU 수신 동의"
        static func agreeNoti(date: String) -> String {
            return "EAT-SSU 수신 동의 (\(date))"
        }
        
        /// MyPageVC - "EAT-SSU 수신 거절"
        static func disagreeNoti(date: String) -> String {
            return "EAT-SSU 수신 거절 (\(date))"
        }

        /// MyPageVC - "알림 설정 중 오류가 발생했습니다."
        static let notiSettingError: String = "알림 설정 중 오류가 발생했습니다."
        
        /// CreatorVC - "만든 사람들"
        static let creators: String = "만든 사람들"

        /// MyReviewVC - "리뷰 수정 혹은 삭제"
        static let fixOrDeleteReview: String = "리뷰 수정 혹은 삭제"
        
        /// MyReviewVC - "작성하신 리뷰를 수정 또는 삭제하시겠습니까?"
        static let askFixOrDeleteReview: String = "작성하신 리뷰를 수정 또는 삭제하시겠습니까?"
        
        /// MyReviewVC - "리뷰 삭제하기"
        static let deleteMyReview: String = "리뷰 삭제하기"
        
        /// MyReviewVC - "해당 리뷰를 삭제할까요?"
        static let askDeleteMyReview: String = "해당 리뷰를 삭제할까요?"
        
        /// MyReviewVC - "리뷰가 성공적으로 삭제되었습니다."
        static let deleteMyReviewSuccess: String = "리뷰가 성공적으로 삭제되었습니다."
        
        /// MyPageView - "다시 시도해주세요"
        static let retry: String = "다시 시도해주세요"
        
        /// MyPageView - "앱 버전"
        static let appVersion: String = "앱 버전"
        
        /// MyPageView - "탈퇴하기"
        static let withdrawButton: String = "탈퇴하기"

        /// MyPageView - "알 수 없음"
        static let unknownUser: String = "알 수 없음"
        
        /// NotificationSettingTableViewCell - "푸시 알림 설정"
        static let pushNotificationSetting: String = "푸시 알림 설정"
        
        /// Push Notification key for UserDefaults
        static let pushNotificationUserSettingKey: String = "pushNotificationUserSettingKey"

        /// NotificationSettingTableViewCell - "매일 오전 11시에 알림을 보내드려요"
        static let pushNotificationDescription: String = "매일 오전 11시에 알림을 보내드려요"

        /// MyPageVC - "문의하기"
        static let inquiry: String = "문의하기"

        /// MyPageVC - "서비스 이용약관"
        static let termsOfUse: String = "서비스 이용약관"

        /// MyPageVC - "개인정보 이용약관"
        static let privacyTermsOfUse: String = "개인정보 이용약관"

        /// ProvisionVC - "이용약관"
        static let defaultTerms: String = "이용약관"

        /// UserWithdrawView - "정말 탈퇴하시겠습니까?"
        static let confirmWithdrawal: String = "정말 탈퇴하시겠습니까?"

        /// UserWithdrawView - "작성한 리뷰 게시글은 삭제되지 않으며, (알수없음)으로 표시됩니다.\n자세한 내용은 서비스이용약관 및 개인정보처리방침을 확인해 주세요."
        static let withdrawalNotice: String = "작성한 리뷰 게시글은 삭제되지 않으며, (알수없음)으로 표시됩니다.\n자세한 내용은 서비스이용약관 및 개인정보처리방침을 확인해 주세요."

        /// UserWithdrawView - "올바른 입력입니다."
        static let validInputMessage: String = "올바른 입력입니다"

        /// UserWithdrawView - "올바르지 않은 닉네임입니다"
        static let invalidNicknameMessage: String = "올바르지 않은 닉네임입니다"
    }
    
    // MARK: - Review
    
    enum Review {
        /// ReportVC - "EAT SSU 팀에게 보내기"
        static let sendToTeam: String = "EAT SSU 팀에게 보내기"
        
        /// ReportVC - "신고하기"
        static let report: String = "신고하기"
        
        /// ReportVC - "사유를 선택해주세요!"
        static let selectReason: String = "사유를 선택해주세요!"
        
        /// ReportVC - "신고가 성공적으로 접수되었어요!"
        static let reportSuccess: String = "신고가 성공적으로 접수되었어요!"
        
        /// ReportVC, ReportView - "메뉴와 관련없는 내용"
        static let unrelatedMenu: String = "메뉴와 관련없는 내용"
        
        /// ReportVC, ReportView - "음란성, 욕설 등 부적절한 내용"
        static let inappropriateContent: String = "음란성, 욕설 등 부적절한 내용"
        
        /// ReportVC, ReportView - "부적절한 홍보 또는 광고"
        static let inappropriateAd: String = "부적절한 홍보 또는 광고"
        
        /// ReportVC, ReportView - "리뷰 작성 취지에 맞지 않는 내용 (복사글 등)"
        static let notReviewFormat: String = "리뷰 작성 취지에 맞지 않는 내용 (복사글 등)"
        
        /// ReportVC, ReportView - "저작권 도용 의심 (사진 등)"
        static let copyright: String = "저작권 도용 의심 (사진 등)"
        
        /// ReportVC, ReportView - "기타 (하단 내용 작성)"
        static let etc: String = "기타 (하단 내용 작성)"
        
        /// ReportView - "리뷰 신고 사유를 알려주세요"
        static let reportReason: String = "리뷰 신고 사유를 알려주세요"
        
        /// ReportView - "하나의 리뷰에 대해 24시간 내 한 번만 신고 가능합니다."
        static let reportGuide: String = "하나의 리뷰에 대해 24시간 내 한 번만 신고 가능합니다."
        
        /// ReportView - "리뷰 신고 사유를 작성해 주세요"
        static let inputReportReason: String = "리뷰 신고 사유를 작성해 주세요"
        
        /// ReviewVC - "리뷰 작성하기"
        static let writeReview: String = "리뷰 작성하기"
        
        /// ReviewVC - "리뷰가 성공적으로 등록되었습니다."
        static let registerReviewSuccess: String = "리뷰가 성공적으로 등록되었습니다."
        
        /// ReviewVC - "리뷰"
        static let review: String = "리뷰"

        /// ReviewVC - "리뷰 삭제"
        static let deleteReview: String = "리뷰 삭제"
        
        /// ReviewVC - "해당 리뷰를 삭제할까요?"
        static let askDeleteReview: String = "해당 리뷰를 삭제할까요?"

        /// ReviewVC - "리뷰 신고하기"
        static let reportReview: String = "리뷰 신고하기"
        
        /// ReviewVC - "해당 리뷰를 신고하시겠습니까?"
        static let askReportReview: String = "해당 리뷰를 신고하시겠습니까?"

        /// ReviewVC - "리뷰가 성공적으로 삭제되었습니다."
        static let deleteReviewSuccess: String = "리뷰가 성공적으로 삭제되었습니다."
        
        /// ReviewVC - "리뷰 삭제에 실패했습니다."
        static let deleteReviewFail: String = "리뷰 삭제에 실패했습니다."
        
        /// SetRateVC - "리뷰 수정하기"
        static let fixReview: String = "리뷰 수정하기"
        
        /// SetRateVC - "리뷰 남기기"
        static let leaveReview: String = "리뷰 남기기"

        /// 메뉴 이름의 받침 유무에 따라 '을/를'을 동적으로 붙여 추천 문장을 생성합니다.
        static func recommendMenu(name: String) -> String {
            guard let lastChar = name.last,
                  let lastScalar = lastChar.unicodeScalars.first else {
                return "\(name)을(를) 추천하시겠어요?" // 예외 처리
            }
            
            // '가' ~ '힣' 사이의 한글 유니코드 범위
            let hangulStart: UInt32 = 0xAC00
            let hangulEnd: UInt32 = 0xD7A3
            
            // 받침이 있는지 계산 (종성 코드 확인)
            if lastScalar.value >= hangulStart && lastScalar.value <= hangulEnd {
                let hasJongseong = (lastScalar.value - hangulStart) % 28 != 0
                if hasJongseong {
                    return "\(name)을 추천하시겠어요?" // 받침 있음
                }
            }
            
            return "\(name)를 추천하시겠어요?" // 받침 없음
        }
        
        /// SetRateVC - "메뉴를 추천하시겠어요?"
        static let recommendMenuTitle: String = "메뉴를 추천하시겠어요?"
        
        /// SetRateVC - "리뷰 수정 완료하기"
        static let fixReviewComplete: String = "리뷰 수정 완료하기"

        /// SetRateVC - "완료하기"
        static let complete: String = "완료하기"
        
        /// SetRateVC - "별점을 입력해주세요!"
        static let inputRating: String = "별점을 입력해주세요!"
        
        /// SetRateVC - "메뉴 목록 조회에 실패했습니다."
        static let loadMenuListFail: String = "메뉴 목록 조회에 실패했습니다."
        
        /// SetRateVC - "수정할 리뷰 정보가 없습니다."
        static let noReviewInfoForFix: String = "수정할 리뷰 정보가 없습니다."

        /// SetRateVC - "리뷰가 성공적으로 수정되었습니다."
        static let fixReviewSuccess: String = "리뷰가 성공적으로 수정되었습니다."
        
        /// SetRateVC - "리뷰 수정에 실패했습니다."
        static let fixReviewFail: String = "리뷰 수정에 실패했습니다."
        
        /// SetRateVC - "식단 정보가 없습니다."
        static let noMealInfo: String = "식단 정보가 없습니다."
        
        /// SetRateVC - "리뷰 업로드에 실패했습니다."
        static let uploadReviewFail: String = "리뷰 업로드에 실패했습니다."
        
        /// SetRateVC - "메뉴 정보가 없습니다."
        static let noMenuInfo: String = "메뉴 정보가 없습니다."
        
        /// SetRateVC - "메뉴에 대한 상세한 리뷰를 작성해주세요"
        static let inputDetailReview: String = "메뉴에 대한 상세한 리뷰를 작성해주세요"
        
        /// SetRateVC - "나가시겠어요?"
        static let askLeave: String = "나가시겠어요?"

        /// SetRateVC - "지금 나가면 작성한 내용이 저장되지 않습니다."
        static let leaveWarning: String = "지금 나가면 작성한 내용이 저장되지 않습니다."

        /// SetRateVC - "나가기"
        static let leave: String = "나가기"
        
        /// SetRateVC - "계속 작성"
        static let continueWriting: String = "계속 작성"
        
        /// ReviewEmptyViewCell - "아직 작성된 리뷰가 없어요!"
        static let noReview: String = "아직 작성된 리뷰가 없어요!"

        /// ReviewEmptyViewCell - "메뉴에 가장 먼저 리뷰를 남겨주세요!"
        static let beFirstReviewer: String = "메뉴에 가장 먼저 리뷰를 남겨주세요!"
        
        /// ReviewEmptyViewCell - "로그인이 필요합니다"
        static let needLogin: String = "로그인이 필요합니다"
        
        /// ReviewEmptyViewCell - "로그인 후 리뷰를 확인하세요"
        static let checkReviewAfterLogin: String = "로그인 후 리뷰를 확인하세요"
        
        /// ReviewEmptyViewCell - "아직 작성한 리뷰가 없어요"
        static let noWrittenReview: String = "아직 작성한 리뷰가 없어요"
        
        /// ReviewEmptyViewCell - "첫 리뷰를 남겨 주세요!"
        static let writeFirstReview: String = "첫 리뷰를 남겨 주세요!"

        /// ReviewDividerCell - "리뷰"
        static func reviewCount(_ count: Int) -> String {
            return "리뷰 \(count)"
        }
        
        /// ReviewRateViewCell - "오늘의 메뉴"
        static let todayMenu: String = "오늘의 메뉴"

        /// ReviewRateViewCell - "5점"
        static let fiveStars: String = "5점"

        /// ReviewRateViewCell - "4점"
        static let fourStars: String = "4점"

        /// ReviewRateViewCell - "3점"
        static let threeStars: String = "3점"

        /// ReviewRateViewCell - "2점"
        static let twoStars: String = "2점"

        /// ReviewRateViewCell - "1점"
        static let oneStar: String = "1점"

        /// SetRateView - "오늘의 식사는 어떠셨나요?"
        static let rateTodayMeal: String = "오늘의 식사는 어떠셨나요?"

        /// SetRateView - "추천하고 싶은 메뉴가 있나요?"
        static let recommendMenu: String = "추천하고 싶은 메뉴가 있나요?"
        
        /// SetRateView - "사진 추가 (0/1)"
        static func addPhoto(count: Int) -> String {
            return "사진 추가 (\(count)/1)"
        }

        /// character count
        static func characterCount(current: Int, max: Int) -> String {
            return "\(current) / \(max)"
        }
    }
    
    // MARK: - Coffee

    enum Coffee {
        /// "나가시겠어요?"
        static let askLeave: String = "나가시겠어요?"

        /// "지금 나가면 진행 상황이\n저장되지 않습니다."
        static let leaveWarning: String = "지금 나가면 진행 상황이\n저장되지 않습니다."

        /// "나가기"
        static let leave: String = "나가기"

        /// "계속하기"
        static let continueEvent: String = "계속하기"
    }

    // MARK: - Splash
    
    enum Splash {
        /// NoticeSplashVC - "긴급 서버 점검 안내"
        static let serverInspection: String = "긴급 서버 점검 안내"
    }

    // MARK: - Notification
    
    enum Notification {
        /// 🤔 오늘 밥 뭐 먹지…
        static let dailyWeekdayNotificationTitle: String = "🤔 오늘 밥 뭐 먹지…"

        /// 오늘의 학식을 확인해보세요!
        static let dailyWeekdayNotificationBody: String = "오늘의 학식을 확인해보세요!"
    }
    
    // MARK: - Restaurant
    
    enum Restaurant {
        /// "기숙사 식당"
        static let dormitoryRestaurant: String = "기숙사 식당"
        /// "도담 식당"
        static let dodamRestaurant: String = "도담 식당"
        /// "학생 식당"
        static let studentRestaurant: String = "학생 식당"
        /// "스낵 코너"
        static let snackCorner: String = "스낵 코너"
        /// "FACULTY (교직원 전용)"
        static let facultyRestaurant: String = "FACULTY (교직원 전용)"
    }
}
