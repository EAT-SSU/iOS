//
//  LocalStorageMigrator.swift
//  EATSSU
//
//  Created by 황상환 on 9/27/26.
//

import UIKit

import RealmSwift

/// 앱 시작 시 로컬 저장소를 준비한다. 토큰·사용자 정보를 읽기 전에 호출해야 한다.
///
/// 1. Realm에 남아 있는 토큰·사용자 정보를 Keychain·UserDefaults로 한 번 옮긴다 (업데이트 사용자)
/// 2. 재설치 후 Keychain에 남은 이전 설치의 토큰을 지운다 (Keychain은 앱을 지워도 남는다)
///
/// Realm 의존성을 제거할 때는 1번과 Legacy 모델만 지우고 2번은 유지한다.
enum LocalStorageMigrator {

    private static let didPrepareKey = "LocalStorageMigrator.didPrepare"

    static func prepareIfNeeded(defaults: UserDefaults = .standard) {
        guard !defaults.bool(forKey: didPrepareKey) else { return }
        // 첫 잠금 해제 전 백그라운드 실행(푸시 등)에서는 UserDefaults·Keychain·Realm 파일을 읽을 수 없어
        // 신규 설치로 오판할 수 있으므로 다음 실행으로 미룬다
        guard UIApplication.shared.isProtectedDataAvailable else { return }

        let realmConfiguration = legacyRealmConfiguration()
        let hasLegacyRealm = realmConfiguration.fileURL
            .map { FileManager.default.fileExists(atPath: $0.path) } ?? false

        if hasLegacyRealm {
            // 한 번만 시도한다. 실패한 채로 재시도하면, 그사이 새로 로그인한 토큰을
            // 나중에 옛 토큰으로 덮어쓸 수 있어 실패 시에는 다시 로그인하게 둔다
            if !migrateFromRealm(configuration: realmConfiguration) {
                TokenStore.clear()
                UserInfoManager.shared.clear()
            }
            _ = try? Realm.deleteFiles(for: realmConfiguration)
        } else {
            TokenStore.clear()
        }

        defaults.set(true, forKey: didPrepareKey)
    }

    // MARK: - Realm → Keychain·UserDefaults

    private struct LegacyData {
        var accessToken: String?
        var refreshToken: String?
        var userInfo: UserInfo?
    }

    /// 기존 AppDelegate 설정과 같은 스키마(version 1)로 기존 default.realm을 연다
    private static func legacyRealmConfiguration() -> Realm.Configuration {
        var configuration = Realm.Configuration.defaultConfiguration
        configuration.schemaVersion = 1
        configuration.objectTypes = [LegacyToken.self, LegacyUserInfo.self]
        return configuration
    }

    /// Realm에 남은 토큰·사용자 정보를 읽는다. 파일을 열 수 없으면 nil
    private static func readLegacyData(configuration: Realm.Configuration) -> LegacyData? {
        autoreleasepool {
            let realm: Realm
            do {
                realm = try Realm(configuration: configuration)
            } catch {
                print("[LocalStorageMigrator] Realm 열기 실패: \(error)")
                return nil
            }

            var data = LegacyData()
            // 기존 RealmService와 같은 기준: 토큰은 마지막 것, 사용자 정보는 첫 번째 것
            if let token = realm.objects(LegacyToken.self).last, !token.accessToken.isEmpty {
                data.accessToken = token.accessToken
                data.refreshToken = token.refreshToken
            }
            if let legacyUserInfo = realm.objects(LegacyUserInfo.self).first {
                data.userInfo = UserInfo(
                    nickname: legacyUserInfo.nickname,
                    accountType: legacyUserInfo.accountTypeRaw.flatMap(UserInfo.AccountType.init(rawValue:)),
                    collegeId: legacyUserInfo.collegeId,
                    collegeName: legacyUserInfo.collegeName,
                    departmentId: legacyUserInfo.departmentId,
                    departmentName: legacyUserInfo.departmentName
                )
            }
            return data
        }
    }

    /// 옮길 데이터가 없거나 모두 옮겼으면 true
    private static func migrateFromRealm(configuration: Realm.Configuration) -> Bool {
        guard let data = readLegacyData(configuration: configuration) else { return false }

        if let accessToken = data.accessToken, let refreshToken = data.refreshToken {
            guard TokenStore.save(accessToken: accessToken, refreshToken: refreshToken) else {
                print("[LocalStorageMigrator] Keychain 저장 실패")
                return false
            }
        }
        if let userInfo = data.userInfo {
            UserInfoManager.shared.save(userInfo)
        }
        print("[LocalStorageMigrator] 이전 완료 (토큰: \(data.accessToken != nil), 사용자 정보: \(data.userInfo != nil))")
        return true
    }
}

// MARK: - Legacy Realm Models

// 기존 Realm 파일을 읽기 위한 모델. 테이블 이름과 속성을 기존 Token·UserInfo와 똑같이 유지해야 한다.

final class LegacyToken: Object {
    override class func _realmObjectName() -> String { "Token" }

    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var accessToken = String()
    @Persisted var refreshToken = String()
}

final class LegacyUserInfo: Object {
    override class func _realmObjectName() -> String { "UserInfo" }

    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var nickname: String = ""
    @Persisted var accountTypeRaw: String?
    @Persisted var collegeId: Int?
    @Persisted var collegeName: String?
    @Persisted var departmentId: Int?
    @Persisted var departmentName: String?
}
