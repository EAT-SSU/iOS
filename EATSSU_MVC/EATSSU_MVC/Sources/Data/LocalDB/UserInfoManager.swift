//
//  UserInfoManager.swift
//  EATSSU
//
//  Created by 최지우 on 9/19/24.
//

import RealmSwift

class UserInfoManager {
    static let shared = UserInfoManager()
    private init() {}
    
    private var realm: Realm {
        do {
            return try Realm()
        } catch {
            fatalError("Realm을 초기화하는데 실패했습니다: \(error)")
        }
    }
    
    func createUserInfo(accountType: UserInfo.AccountType) -> UserInfo {
        let userInfo = UserInfo(accountType: accountType)
        do {
            try realm.write {
                realm.add(userInfo)
            }
            return userInfo
        } catch {
            print("UserInfo 생성 중 오류 발생: \(error)")
            return userInfo
        }
    }
    
    func updateNickname(for userInfo: UserInfo, nickname: String) {
        do {
            try realm.write {
                userInfo.updateNickname(nickname)
            }
        } catch {
            print("닉네임 업데이트 중 오류 발생: \(error)")
        }
    }
    
    func getCurrentUserInfo() -> UserInfo? {
        return realm.objects(UserInfo.self).first
    }
}
