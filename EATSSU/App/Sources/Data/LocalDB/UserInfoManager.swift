//
//  UserInfoManager.swift
//  EATSSU
//
//  Created by 최지우 on 9/19/24.
//

import Foundation

/// 사용자 프로필을 UserDefaults에 JSON으로 저장한다.
/// 값 몇 개뿐이라 DB 없이 통째로 읽고 쓴다.
final class UserInfoManager {
    static let shared = UserInfoManager()

    private let defaults: UserDefaults
    private let storageKey = "localUserInfo"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func getCurrentUserInfo() -> UserInfo? {
        guard let data = defaults.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(UserInfo.self, from: data)
    }

    /// 로그인 직후 새 프로필을 만든다. 이전 프로필은 대체된다.
    @discardableResult
    func createUserInfo(accountType: UserInfo.AccountType) -> UserInfo {
        let userInfo = UserInfo(accountType: accountType)
        save(userInfo)
        return userInfo
    }

    func save(_ userInfo: UserInfo) {
        guard let data = try? JSONEncoder().encode(userInfo) else { return }
        defaults.set(data, forKey: storageKey)
    }

    func updateUserInfo(nickname: String, collegeId: Int?, collegeName: String?, departmentId: Int?, departmentName: String?) {
        update {
            $0.nickname = nickname
            $0.collegeId = collegeId
            $0.collegeName = collegeName
            $0.departmentId = departmentId
            $0.departmentName = departmentName
        }
    }

    func updateNickname(_ nickname: String) {
        update { $0.nickname = nickname }
    }

    func updateDepartment(collegeId: Int?, collegeName: String?, departmentId: Int?, departmentName: String?) {
        update {
            $0.collegeId = collegeId
            $0.collegeName = collegeName
            $0.departmentId = departmentId
            $0.departmentName = departmentName
        }
    }

    func clear() {
        defaults.removeObject(forKey: storageKey)
    }

    /// 프로필이 있을 때만 수정한다 (로그인 전에는 무시)
    private func update(_ change: (inout UserInfo) -> Void) {
        guard var userInfo = getCurrentUserInfo() else { return }
        change(&userInfo)
        save(userInfo)
    }
}
