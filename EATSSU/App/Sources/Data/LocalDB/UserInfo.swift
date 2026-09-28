//
//  UserInfo.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/08/02.
//

import Foundation

/// 로그인한 사용자의 로컬 프로필. UserInfoManager가 UserDefaults에 저장한다.
struct UserInfo: Codable, Equatable {
    var nickname: String = ""
    var accountType: AccountType?
    var collegeId: Int?
    var collegeName: String?
    var departmentId: Int?
    var departmentName: String?

    enum AccountType: String, Codable {
        case apple = "Apple"
        case kakao = "Kakao"
    }
}
