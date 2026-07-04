//
//  KeychainHelper.swift
//  EATSSU
//
//  Created by 황상환 on 7/4/26.
//

import Foundation
import Security

/// 문자열 값을 Keychain에 저장/조회하는 최소 헬퍼.
/// UserDefaults와 달리 앱 재설치 후에도 값이 유지된다.
enum KeychainHelper {

    /// 값을 저장한다. 같은 key가 있으면 덮어쓴다.
    @discardableResult
    static func save(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)

        var attributes = query
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        return SecItemAdd(attributes as CFDictionary, nil) == errSecSuccess
    }

    /// 값을 조회한다. 없으면 nil.
    static func read(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        return value
    }
}
