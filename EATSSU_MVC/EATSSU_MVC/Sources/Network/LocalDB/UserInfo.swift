//
//  NickName.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/08/02.
//

import RealmSwift
import Realm

class UserInfo: Object {

    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var nickname: String = ""
    @Persisted private var accountTypeRaw: String?

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
    
    func updateNickname(_ nickname: String) {
        self.nickname = nickname
    }
    
    enum AccountType: String {
        case apple = "Apple"
        case kakao = "Kakao"
    }
}
