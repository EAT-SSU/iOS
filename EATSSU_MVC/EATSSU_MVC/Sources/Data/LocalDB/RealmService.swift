//
//  RealmService.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/05/27.
//

import RealmSwift
import Realm

class RealmService{
    
    static let shared = RealmService()
    
    let realm = try! Realm()
    
    init() {
        print("Realm Location: ", realm.configuration.fileURL ?? "cannot find location.")
    }

    func addToken(accessToken:String,refreshToken:String) {
        let token = Token(accessToken: accessToken,refreshToken: refreshToken)
        try! realm.write{
            realm.add(token)
        }
    }

    func getToken() -> String {
        let token = realm.objects(Token.self)
        return token.last?.accessToken ?? ""
    }

    func getRefreshToken() -> String {
        let token = realm.objects(Token.self)
        return token.last?.refreshToken ?? ""
    }
    
    func isAccessTokenPresent() -> Bool {
        return getToken() != ""
    }

    // 스키마 수정시 한번 돌려야 한다.
    func resetDB(){
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func deleteAll<T: Object>(_ objectType: T.Type) {
        do {
            let objects = realm.objects(objectType)
            try realm.write {
                realm.delete(objects)
                print("Successfully deleted all objects of type \(objectType)")
            }
        } catch let error {
            print(error)
        }
    }
}


