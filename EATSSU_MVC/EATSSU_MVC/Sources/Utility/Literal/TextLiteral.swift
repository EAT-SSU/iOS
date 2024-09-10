//
//  TextLiteral.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/06/27.
//

import UIKit

enum TextLiteral {
    
    // MARK: - sign in
    
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
    
    // MARK: - home
    
    static let menu: String = "오늘의 메뉴"
    static let price: String = "가격"
    static let rating: String = "평점"
    static let emptyRating: String = "  -"
    
    // MARK: - restaurant
    
    static let dormitoryRestaurant: String = "기숙사 식당"
    static let dodamRestaurant: String = "도담 식당"
    static let studentRestaurant: String = "학생 식당"
    static let foodCourt: String = "푸드 코트"
    static let snackCorner: String = "스낵 코너"
    static let dormitoryRawValue: String = "DORMITORY"
    static let dodamRawValue: String = "DODAM"
    static let studentRestaurantRawValue: String = "HAKSIK"
    static let foodCourtRawValue: String = "FOOD_COURT"
    static let snackCornerRawValue: String = "SNACK_CORNER"
    static let lunchRawValue: String = "LUNCH"

    // MARK: - myPage
    
    static let myPage: String = "마이페이지"
    static let linkedAccount: String = "연결된 계정"
    static let myReview: String = "내가 쓴 리뷰"
    static let logout: String = "로그아웃"
    static let withdraw: String = "탈퇴하기"
    static let defaultTerms: String = "이용약관"
    static let termsOfUse: String = "서비스 이용약관"
    static let privacyTermsOfUse: String = "개인정보 이용약관"
    static let appVersion: String = "앱 버전"
    static let changeNickname: String = "닉네임 변경"
    static let newNickname: String = "새로운 닉네임"
    static let existingNickname: String = "기존 닉네임"
    static let inquiry: String = "문의하기"
    static let inputEmail: String = "답변받을 이메일 주소를 남겨주세요."
  /// "정말 탈퇴하시겠습니까?"
    static let signOut = "정말 탈퇴하시겠습니까?"
    static let signOutSubscription = "작성한 리뷰 게시글은 삭제되지 않으며, (알수없음)으로 표시됩니다.\n자세한 내용은 서비스이용약관 및 개인정보처리방침을 확인해 주세요."
    static let correctInput = "올바른 입력입니다"
    static let uncorrectNickName = "올바르지 않은 닉네임입니다"
    static let termsOfUseText: String = """
최종 수정일: 2023년 11월 20일

***제 1조(목적)***
본 약관은 "EAT-SSU" 서비스(이하 "서비스"라 함)의 이용과 관련하여, 서비스를 제공하는 주체(이하 "회사"라 함)와 서비스 이용자(이하 "이용자"라 함) 간의 권리, 의무, 책임사항, 서비스 이용 조건, 절차 및 방법 등을 규정함을 목적으로 합니다.

***제 2조(정의)***
본 약관에서 사용하는 용어의 정의는 다음과 같습니다:

"회사"라 함은 서비스를 제공하는 주체를 말합니다.
"이용자"라 함은 본 약관에 따라 "회사"가 제공하는 "서비스"를 이용하는 회원 및 비회원을 말합니다.
"회원"이라 함은 "회사"와 이용계약을 체결하고 "이용자"가 소셜 로그인을 통해 등록한 정보로 "서비스"를 이용할 수 있는 자를 말합니다. 소셜 로그인은 카카오로그인 및 애플로그인을 포함합니다.
"비회원"이라 함은 "회원"이 아니면서 "회사"가 제공하는 서비스를 이용하는 자를 말합니다.
"서비스"라 함은 "EAT-SSU"가 제공하는 서비스로, 숭실대학교 교내식당 메뉴 정보 제공, 메뉴의 별점 및 리뷰 제공, 리뷰 작성 기능 제공, 리뷰 수정 및 삭제 기능 등을 포함합니다.
"이메일"이라 함은 "회원"의 식별과 서비스 이용을 위하여 "회원"이 제공한 이메일 주소를 말합니다.
"닉네임"이라 함은 회원간 상호를 식별하기 위한 사용자 이름을 말합니다.
"리뷰"라 함은 사용자가 서비스 내에서 작성하고 공유하는 의견 및 평가 내용을 말합니다.
본 조항 1항에서 정의되지 않은 약관 내 용어의 의미는 일반적인 이용관행에 따릅니다.

***제 3조(서비스 제공)***
회사는 "EAT-SSU" 서비스를 제공합니다. 이 서비스는 숭실대학교 교내식당 메뉴 정보 제공, 메뉴의 별점 및 리뷰 제공, 리뷰 작성 기능 제공, 리뷰 수정 및 삭제 기능 등을 포함합니다.

회사는 운영상, 기술상의 필요에 따라 제공하고 있는 서비스를 변경할 수 있습니다.

회사는 이용자의 개인정보 및 서비스 이용 기록에 따라 서비스 이용에 차이를 둘 수 있습니다.

회사는 천재지변, 인터넷 장애, 경영 약화 등으로 서비스를 더 이상 제공하기 어려울 경우, 서비스를 통보 없이 중단할 수 있습니다.

회사는 서비스 제공과 관련하여 법률이나 본 약관에 따른 모든 서비스, 게시물, 이용 기록의 진본성, 무결성, 신뢰성, 이용가능성을 보장하지 않습니다.

***제 4조(개인정보의 관리 및 보호)***
회원은 회원가입 시 등록한 이메일 주소에 변동이 있을 경우, 즉시 "내 정보" 메뉴 등을 이용하여 정보를 최신화해야 합니다.

회원의 이메일 주소 및 비밀번호 등 모든 개인정보의 관리책임은 본인에게 있으므로, 타인에게 양도 및 대여할 수 없으며, 유출되지 않도록 관리해야 합니다. 만약 본인의 이메일 주소 및 비밀번호를 타인이 사용하고 있음을 인지했을 경우 바로 서비스 내부의 문의 창구에 알려야 하고, 안내가 있는 경우 이에 즉시 따라야 합니다.

회사는 2항부터 전항까지를 이행하지 않아 발생한 피해에 대해 어떠한 책임을 지지 않습니다.

***제 5조(회원 탈퇴 및 리뷰 보존)***
"회원"은 "회사"에 언제든지 탈퇴를 요청할 수 있으며 "회사"는 즉시 회원탈퇴를 처리합니다.

"회원"이 리뷰 작성 등의 활동으로 인해 서비스 내에서 유용한 정보를 제공하였을 경우, 탈퇴 후에도 해당 리뷰는 "알 수 없음" 사용자로 남겨질 수 있습니다. 리뷰 삭제 및 탈퇴를 원하시는 경우, 리뷰를 삭제한 후 탈퇴하시기를 권장합니다.

***제 6조(저작권)***
이용자가 "EAT-SSU" 서비스 내에서 작성한 리뷰에 관한 저작권은 해당 리뷰를 작성한 이용자에게 귀속됩니다.

회사는 리뷰 내에서 포함된 아이디어, 디자인, 노하우 등(이하 "아이디어 등"이라 함)을 서비스 개선, 신상품 개발, 홍보 등의 목적으로 이용할 수 있습니다. 이 경우, 해당 아이디어 등에 대한 저작자의 인격권을 침해하지 않으며, 아이디어 등의 사용에 대한 별도의 보상을 제공하지 않습니다.

***제 7조(금지행위)***
이용자는 다음과 같은 행위를 해서는 안됩니다:

개인정보 또는 계정 기만, 침해, 공유 행위
시스템 부정행위
업무 방해 행위
기타 현행법에 어긋나거나 부적절하다고 판단되는 행위
이용자가 1항에 해당하는 행위를 할 경우, 회사는 해당 행위에 따라 서비스 이용 권한을 제한하거나 회원가입을 취소할 수 있습니다.

회사는 1항부터 2항까지로 인해 발생한 피해에 대해 어떠한 책임을 지지 않으며, 이용자는 귀책사유로 인해 발생한 모든 손해를 배상할 책임이 있습니다.

***제 8조(광고의 게재 및 알림)***
회사는 서비스 내에서 광고를 게재할 수 있으며, 광고성 정보 수신에 동의한 경우, 서비스 내부 알림 수단과 연락처를 이용하여 광고성 정보를 발신할 수 있습니다.

야간 광고전송에 대한 수신

회사는 오후 9시~익일 오전 8시까지 광고 푸시를 전송하는 경우, 광고성 정보가 시작되는 부분에 (광고), 전송자의 명칭을 표시합니다.
광고성 정보가 끝나는 부분에 수신 거부 또는 수신동의 철회를 할 수 있는 방식을 명시합니다.

***제 9조(리뷰 신고)***
이용자는 하루에 한 번만 리뷰를 신고할 수 있습니다.

리뷰에 신고가 3회 누적되면 관리자가 이를 확인하고 삭제할 수 있습니다.

***제 10조(기타)***
본 약관은 2023년 11월 20일에 최신화 되었습니다.

본 약관에서 정하지 아니한 사항과 본 약관의 해석에 관하여는 관련법 또는 관례에 따릅니다.

본 약관은 "EAT-SSU" 서비스의 이용에 관한 중요한 규정을 포함하고 있으며, 이를 숙지하고 서비스를 이용하시기를 바랍니다. 서비스 이용 시 본 약관의 규정을 준수해주시기를 요청드립니다.
"""
    
    static let privacyTermsOfUseText: String = """
최종 수정일: 2023년 11월 20일

***제 1조(개인정보 수집 목적)***
"EAT-SSU" 서비스(이하 "서비스")의 제공과 관련하여, 서비스를 제공하는 주체(이하 "회사")와 서비스 이용자(이하 "이용자") 간의 개인정보 처리방침을 목적으로 합니다. 이 방침은 개인정보 수집, 이용, 보관, 제공, 관리 등과 관련한 이용자의 권리, 회사의 의무를 규정합니다.

***제 2조(수집하는 개인정보 항목 및 이용 목적)***
회원가입 시
유형: 회원
필수 수집 항목: 소셜 로그인 계정 정보 (카카오, 애플)
수집 목적: 회원 가입, 서비스 제공, 계정 관리, 안내/고지, 사용자 상담
리뷰 작성 시
유형: 회원
수집 항목: 닉네임, 리뷰 내용, 사진
수집 목적: 리뷰 작성 및 서비스 품질 향상

***제 3조(수집한 정보의 이용 방법)***
회사는 수집한 정보를 다음과 같은 목적으로 이용합니다:

서비스 제공 및 개선
사용자 상담 및 응대
리뷰 작성 및 관리
서비스 운영상, 기술상의 필요에 따른 변경
법령 및 약관 준수 등

***제 4조(개인정보의 보유 및 보존 기간)***
"회원"의 경우 회원 탈퇴일로부터 30일 동안 개인정보를 보유한 후 삭제합니다.

***제 5조(개인정보의 제3자 제공)***
회사는 이용자의 개인정보를 본래의 수집 및 이용 목적 범위를 초과하여 제3자에게 제공하지 않습니다. 다만, 다음의 경우에는 예외로 합니다:

이용자의 동의가 있는 경우
법령의 규정에 따라 제공이 요구되는 경우

***제 6조(안전성 확보 조치)***
회사는 개인정보의 안전성 확보를 위해 다음과 같은 조치를 취합니다:

개인정보 암호화 전송
해킹 등에 대비한 기술적 대책
개인정보에 대한 접근 제한

***제 7조(이용자의 권리와 행사 방법)***
이용자는 다음과 같은 권리를 행사할 수 있습니다:

개인정보 열람, 정정, 삭제 요청
개인정보 처리 일시 중지 요청
개인정보 이전 동의 철회 요청

***제 8조(개인정보보호책임자)***
성명: 유진
메일: jini1514@soongsil.ac.kr

***제 9조(정책 변경)***
회사는 개인 정보 보호 정책을 업데이트할 수 있으며 변경 사항은 해당 페이지에 게시된 직후 적용됩니다.

***제 10조(적용일)***
본 개인정보 처리방침은 2023년 11월 20일부터 적용됩니다.
"""
    
    
    static let request = "문의할 내용을 남겨주세요."
    static let email = "이메일"
    static let requestContent = "문의내용"
    static let requestContentGuide = "여기에 내용을 작성해주세요."
    static let requestMaximumText = "0 / 500"
    static let send = "전송하기"
}

 
