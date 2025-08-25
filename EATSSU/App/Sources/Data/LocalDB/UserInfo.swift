//
//  UserInfo.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/08/02.
//

import Realm
import RealmSwift

class UserInfo: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var nickname: String = ""
    @Persisted private var accountTypeRaw: String?
    @Persisted var collegeId: Int?
    @Persisted var collegeName: String?
    @Persisted var departmentId: Int?
    @Persisted var departmentName: String?

    var accountType: AccountType? {
        get {
            guard let rawValue = accountTypeRaw else { return nil }
            return AccountType(rawValue: rawValue)
        }
        set {
            accountTypeRaw = newValue?.rawValue
        }
    }

    convenience init(accountType: AccountType) {
        self.init()
        self.accountType = accountType
    }
    
    func updateUserInfo(nickname: String, collegeId: Int?, collegeName: String?, departmentId: Int?, departmentName: String?) {
        self.nickname = nickname
        self.collegeId = collegeId
        self.collegeName = collegeName
        self.departmentId = departmentId
        self.departmentName = departmentName
    }

    func updateNickname(_ nickname: String) {
        self.nickname = nickname
    }
    
    func updateDepartment(collegeId: Int?, collegeName: String?, departmentId: Int?, departmentName: String?) {
        self.collegeId = collegeId
        self.collegeName = collegeName
        self.departmentId = departmentId
        self.departmentName = departmentName
    }

    enum AccountType: String {
        case apple = "Apple"
        case kakao = "Kakao"
    }
}
