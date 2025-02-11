//
//  UserInfoManager.swift
//  EATSSU
//
//  Created by 최지우 on 9/19/24.
//

import RealmSwift

/// `UserInfoManager`는 Realm 데이터베이스를 사용하여 `UserInfo` 객체를 생성, 수정, 조회하는 기능을 제공하는 싱글턴 클래스입니다.
///
/// 이 클래스는 애플리케이션 전반에 걸쳐 사용자 정보를 효율적으로 관리할 수 있도록 설계되었습니다.
class UserInfoManager {
    /// 애플리케이션 전역에서 접근 가능한 싱글턴 인스턴스
    static let shared = UserInfoManager()

    /// 외부에서의 인스턴스 생성을 방지하기 위한 private 초기화 메서드
    private init() {}

    /// Realm 데이터베이스 인스턴스를 반환합니다.
    ///
    /// Realm 초기화 과정에서 오류가 발생하면, 해당 오류를 출력한 후 애플리케이션이 크래시됩니다.
    private var realm: Realm {
        do {
            return try Realm()
        } catch {
            fatalError("Realm을 초기화하는데 실패했습니다: \(error)")
        }
    }

    /// 지정된 계정 유형을 기반으로 새로운 `UserInfo` 객체를 생성하고, 이를 Realm 데이터베이스에 저장합니다.
    ///
    /// - Parameter accountType: 생성할 `UserInfo` 객체의 계정 유형.
    /// - Returns: Realm에 저장된 새 `UserInfo` 객체.
    /// - Note: 저장 과정에서 오류가 발생하면, 오류 메시지를 출력한 후 생성된 객체를 반환합니다.
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

    /// 주어진 `UserInfo` 객체의 닉네임을 업데이트합니다.
    ///
    /// - Parameters:
    ///   - userInfo: 닉네임을 업데이트할 대상 `UserInfo` 객체.
    ///   - nickname: 적용할 새로운 닉네임.
    /// - Note: 업데이트 과정에서 오류가 발생하면, 해당 오류를 출력합니다.
    func updateNickname(for userInfo: UserInfo, nickname: String) {
        do {
            try realm.write {
                userInfo.updateNickname(nickname)
            }
        } catch {
            print("닉네임 업데이트 중 오류 발생: \(error)")
        }
    }

    /// Realm 데이터베이스에 저장된 첫 번째 `UserInfo` 객체를 조회하여 반환합니다.
    ///
    /// - Returns: 존재하는 경우 첫 번째 `UserInfo` 객체, 그렇지 않으면 `nil`.
    func getCurrentUserInfo() -> UserInfo? {
        realm.objects(UserInfo.self).first
    }
}
