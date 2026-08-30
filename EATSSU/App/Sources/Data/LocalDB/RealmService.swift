//
//  RealmService.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/05/27.
//

import Realm
import RealmSwift

class RealmService {
    static let shared = RealmService()

    private init() {
        let realm = try! Realm()
        print("Realm Location: ", realm.configuration.fileURL ?? "cannot find location.")
    }

    func addToken(accessToken: String, refreshToken: String) {
        let realm = try! Realm()
        let token = Token(accessToken: accessToken, refreshToken: refreshToken)
        let existingToken = realm.objects(Token.self)

        try! realm.write {
            realm.delete(existingToken)
            realm.add(token)
        }
    }

    func getToken() -> String {
        let realm = try! Realm()
        let token = realm.objects(Token.self)
        return token.last?.accessToken ?? ""
    }

    func getRefreshToken() -> String {
        let realm = try! Realm()
        let token = realm.objects(Token.self)
        return token.last?.refreshToken ?? ""
    }

    func isAccessTokenPresent() -> Bool {
        return getToken() != ""
    }

    func resetDB() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        // 계정 단위 상태도 함께 초기화 (찜 목록·순서)
        PartnershipLikeManager.shared.reset()
    }

    func deleteAll(_ objectType: (some Object).Type) {
        let realm = try! Realm()
        let objects = realm.objects(objectType)
        try! realm.write {
            realm.delete(objects)
            print("Successfully deleted all objects of type \(objectType)")
        }
    }
}
