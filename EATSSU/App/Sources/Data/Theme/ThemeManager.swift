//
//  ThemeManager.swift
//  EATSSU
//
//  Created by Claude on 2026/04/03.
//

import UIKit

final class ThemeManager {
    static let shared = ThemeManager()

    private let userDefaultsKey = "appliedAppTheme"

    private init() {}

    /// 현재 적용된 테마 (UserDefaults에 저장)
    var appliedTheme: AppTheme {
        get {
            guard let raw = UserDefaults.standard.string(forKey: userDefaultsKey),
                  let theme = AppTheme(rawValue: raw)
            else { return .default }
            return theme
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: userDefaultsKey)
        }
    }

    /// Remote Config에서 받은 테마를 적용. 테마가 변경되면 아이콘 전환.
    func applyRemoteTheme(_ remoteThemeString: String, completion: @escaping () -> Void) {
        let remoteTheme = AppTheme(rawValue: remoteThemeString) ?? .default

        guard remoteTheme != appliedTheme else {
            completion()
            return
        }

        guard UIApplication.shared.supportsAlternateIcons else {
            appliedTheme = remoteTheme
            completion()
            return
        }

        let iconName = remoteTheme.alternateIconName
        print("[ThemeManager] setAlternateIconName 호출: \(iconName ?? "nil (기본)")")

        UIApplication.shared.setAlternateIconName(iconName) { [weak self] error in
            DispatchQueue.main.async {
                if let error {
                    print("[ThemeManager] 아이콘 변경 실패: \(error.localizedDescription)")
                } else {
                    print("[ThemeManager] 아이콘 변경 성공!")
                    self?.appliedTheme = remoteTheme
                }
                completion()
            }
        }
    }

}
