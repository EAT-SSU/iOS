//
//  Token.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/05/27.
//

import Realm
import RealmSwift

/// 나중에
class Token: Object {
    @Persisted(primaryKey: true) var _id: ObjectId

    @Persisted var accessToken = String()
    @Persisted var refreshToken = String()

    override static func primaryKey() -> String? {
        return "token"
    }

    convenience init(accessToken: String, refreshToken: String) {
        self.init()
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
