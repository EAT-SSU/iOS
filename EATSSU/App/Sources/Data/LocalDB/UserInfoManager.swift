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
    
    func updateUserInfo(for userInfo: UserInfo, nickname: String, collegeId: Int?, collegeName: String?, departmentId: Int?, departmentName: String?) {
        do {
            try realm.write {
                userInfo.updateUserInfo(nickname: nickname,
                                        collegeId: collegeId,
                                        collegeName: collegeName,
                                        departmentId: departmentId,
                                        departmentName: departmentName)
            }
        } catch {
            print("사용자 정보 업데이트 중 오류 발생: \(error)")
        }
    }

    func updateNickname(for userInfo: UserInfo, nickname: String) {
        do {
            try realm.write {
                userInfo.updateNickname(nickname) // UserInfo.swift에 있는 함수 호출
            }
        } catch {
            print("닉네임 정보 업데이트 중 오류 발생: \(error)")
        }
    }
    
    func updateDepartment(for userInfo: UserInfo, collegeId: Int?, collegeName: String?, departmentId: Int?, departmentName: String?) {
        do {
            try realm.write {
                userInfo.updateDepartment(collegeId: collegeId,
                                        collegeName: collegeName,
                                        departmentId: departmentId,
                                        departmentName: departmentName)
            }
        } catch {
            print("학과 정보 업데이트 중 오류 발생: \(error)")
        }
    }
    
    func getCurrentUserInfo() -> UserInfo? {
        realm.objects(UserInfo.self).first
    }
}
