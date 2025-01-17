//
//  CacheManager.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 12/31/24.
//

import Foundation

final class CacheManager {
    static let shared = CacheManager()
    private let cacheKey = "widgetData"

    func fetchCachedData() -> String? {
        return UserDefaults.standard.string(forKey: cacheKey)
    }

    func saveCachedData(_ data: String) {
        UserDefaults.standard.set(data, forKey: cacheKey)
    }
}
