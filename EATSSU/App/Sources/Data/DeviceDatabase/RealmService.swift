//
//  RealmService.swift
//  EATSSU
//
//  Edited by Jiwoong CHOI on 02/11/2025
//

import Realm
import RealmSwift

/// Realm 데이터베이스와 상호작용을 관리하는 서비스 클래스입니다.
///
/// 이 싱글톤 서비스는 토큰을 저장 및 조회하는 메서드를 제공하며,
/// 데이터베이스를 초기화하거나 특정 타입의 객체를 삭제하는 등 일반적인 데이터베이스 작업을 수행합니다.
class RealmService {
    /// `RealmService`의 공유 싱글톤 인스턴스입니다.
    static let shared = RealmService()

    /// Realm 데이터베이스 인스턴스입니다.
    let realm = try! Realm()

    /// RealmService의 새 인스턴스를 초기화하고, Realm 데이터베이스 파일의 위치를 출력합니다.
    ///
    /// 이 메서드는 `RealmService.shared`에 접근할 때 자동으로 호출됩니다.
    init() {
        #if DEBUG
            print("Realm 위치: ", realm.configuration.fileURL ?? "위치를 찾을 수 없습니다.")
        #endif
    }

    /// Realm 데이터베이스에 새로운 토큰을 추가합니다.
    ///
    /// - Parameters:
    ///   - accessToken: 접근 토큰을 나타내는 `String`입니다.
    ///   - refreshToken: 리프레시 토큰을 나타내는 `String`입니다.
    func addToken(accessToken: String, refreshToken: String) {
        let token = Token(accessToken: accessToken, refreshToken: refreshToken)
        try! realm.write {
            realm.add(token)
        }
    }

    /// Realm 데이터베이스에 저장된 최신 접근 토큰을 조회합니다.
    ///
    /// - Returns: 접근 토큰을 포함하는 `String`입니다. 토큰이 없는 경우 빈 문자열을 반환합니다.
    func getToken() -> String {
        let token = realm.objects(Token.self)
        return token.last?.accessToken ?? ""
    }

    /// Realm 데이터베이스에 저장된 최신 리프레시 토큰을 조회합니다.
    ///
    /// - Returns: 리프레시 토큰을 포함하는 `String`입니다. 토큰이 없는 경우 빈 문자열을 반환합니다.
    func getRefreshToken() -> String {
        let token = realm.objects(Token.self)
        return token.last?.refreshToken ?? ""
    }

    /// Realm 데이터베이스에 접근 토큰이 존재하는지 확인합니다.
    ///
    /// - Returns: 접근 토큰이 존재하면 `true`, 그렇지 않으면 `false`를 반환합니다.
    func isAccessTokenPresent() -> Bool {
        getToken() != ""
    }

    /// Realm 데이터베이스를 초기화하여 모든 저장된 객체를 삭제합니다.
    ///
    /// **주의:** 이 메서드는 스키마 변경 후와 같이 꼭 필요할 때만 사용해야 합니다.
    func resetDB() {
        try! realm.write {
            realm.deleteAll()
        }
    }

    /// Realm 데이터베이스에서 특정 타입의 모든 객체를 삭제합니다.
    ///
    /// - Parameter objectType: 삭제할 객체의 타입입니다. 이 타입은 `Object` 프로토콜을 준수해야 합니다.
    ///
    /// 삭제가 성공하면 확인 메시지가 출력되며, 오류가 발생하면 해당 오류를 출력합니다.
    func deleteAll(_ objectType: (some Object).Type) {
        do {
            let objects = realm.objects(objectType)
            try realm.write {
                realm.delete(objects)
                #if DEBUG
                    print("타입 \(objectType)의 모든 객체를 성공적으로 삭제했습니다.")
                #endif
            }
        } catch {
            #if DEBUG
                print(error.localizedDescription)
            #endif
        }
    }
}
