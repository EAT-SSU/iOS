//
//  TokenStore.swift
//  EATSSU
//
//  Created by 황상환 on 9/27/26.
//

import Foundation
import Security

/// 로그인 토큰을 Keychain에 저장한다.
/// 요청마다 읽히므로 메모리에 캐시하고, 여러 스레드(네트워크 인터셉터·메인)에서 접근하므로 잠금으로 보호한다.
enum TokenStore {

    private enum Key {
        static let accessToken = "auth.accessToken"
        static let refreshToken = "auth.refreshToken"
    }

    /// 백업·기기 이전으로 다른 기기에 복원되지 않도록 이 기기에만 보관
    private static let accessibility = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

    private static let lock = NSLock()
    nonisolated(unsafe) private static var cachedAccessToken: String?
    nonisolated(unsafe) private static var cachedRefreshToken: String?

    static var accessToken: String {
        value(forKey: Key.accessToken, cache: &cachedAccessToken)
    }

    static var refreshToken: String {
        value(forKey: Key.refreshToken, cache: &cachedRefreshToken)
    }

    static var hasAccessToken: Bool {
        !accessToken.isEmpty
    }

    /// 토큰 두 개를 함께 저장한다.
    /// 하나라도 실패하면 서로 다른 세대의 토큰이 섞이지 않도록 둘 다 지우고 false를 반환한다.
    @discardableResult
    static func save(accessToken: String, refreshToken: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        let isAccessSaved = KeychainHelper.save(accessToken, forKey: Key.accessToken, accessibility: accessibility)
        let isRefreshSaved = KeychainHelper.save(refreshToken, forKey: Key.refreshToken, accessibility: accessibility)
        guard isAccessSaved && isRefreshSaved else {
            KeychainHelper.delete(forKey: Key.accessToken)
            KeychainHelper.delete(forKey: Key.refreshToken)
            cachedAccessToken = ""
            cachedRefreshToken = ""
            return false
        }
        cachedAccessToken = accessToken
        cachedRefreshToken = refreshToken
        return true
    }

    static func clear() {
        lock.lock()
        defer { lock.unlock() }

        KeychainHelper.delete(forKey: Key.accessToken)
        KeychainHelper.delete(forKey: Key.refreshToken)
        cachedAccessToken = ""
        cachedRefreshToken = ""
    }

    private static func value(forKey key: String, cache: inout String?) -> String {
        lock.lock()
        defer { lock.unlock() }

        if let cache { return cache }
        // 읽기 실패(첫 잠금 해제 전 등)는 캐시하지 않아, 잠금 해제 후 다시 읽을 수 있게 한다
        guard let stored = KeychainHelper.read(forKey: key) else { return "" }
        cache = stored
        return stored
    }
}
