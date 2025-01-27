//
//  AppStoreCheck.swift
//  EAT-SSU
//
//  Created by 최지우 on 12/6/23.
//

import UIKit

/// `AppStoreCheck` 클래스는 앱의 현재 버전 및 빌드 번호를 확인하고,
/// App Store에서 최신 버전을 조회하여 업데이트를 유도할 수 있도록 합니다.
class AppStoreCheck {
    /// 앱의 현재 버전 (CFBundleShortVersionString에서 가져옴)
    ///
    /// - 위치: 타겟 설정 > 일반 > 버전
    static let appVersion: String? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

    /// 앱의 빌드 번호 (CFBundleVersion에서 가져옴)
    ///
    /// - 위치: 타겟 설정 > 일반 > 빌드
    static let buildNumber: String? = Bundle.main.infoDictionary?["CFBundleVersion"] as? String

    /// 앱스토어의 해당 앱 페이지로 이동할 수 있는 URL 문자열입니다.
    ///
    /// - 예제: `itms-apps://itunes.apple.com/app/apple-store/6472618331`
    static let appStoreOpenUrlString: String = "itms-apps://itunes.apple.com/app/apple-store/6472618331"

    /// 앱스토어에서 최신 버전을 확인하는 메서드입니다.
    ///
    /// - Returns: 앱스토어에 등록된 최신 버전 문자열 (예: `"1.2.3"`), 실패 시 `nil` 반환.
    ///
    /// - Note: iTunes API를 호출하여 `lookup` 엔드포인트에서 버전 정보를 가져옵니다.
    /// - Warning: 네트워크 요청이 실패할 수 있으므로 반드시 네트워크 상태를 확인해야 합니다.
    func latestVersion() -> String? {
        let appleID = "6472618331"
        guard let url = URL(string: "https://itunes.apple.com/lookup?id=\(appleID)&country=kr"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
              let results = json["results"] as? [[String: Any]],
              let appStoreVersion = results.first?["version"] as? String
        else {
            return nil
        }
        return appStoreVersion
    }

    /// 앱스토어의 해당 앱 페이지로 이동합니다.
    ///
    /// - Description: `appStoreOpenUrlString`을 사용하여 앱스토어 페이지로 연결합니다.
    /// - Note: URL이 유효한지 확인한 후 `UIApplication.shared.open`을 사용합니다.
    func openAppStore() {
        guard let url = URL(string: AppStoreCheck.appStoreOpenUrlString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
