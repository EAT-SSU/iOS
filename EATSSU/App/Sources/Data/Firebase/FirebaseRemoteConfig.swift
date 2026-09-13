//
//  FirebaseRemoteConfig.swift
//  EAT-SSU
//
//  Created by 최지우 on 3/6/24.
//

import Foundation

import Firebase

class FirebaseRemoteConfig {
    static let shared = FirebaseRemoteConfig()
    var remoteConfig: RemoteConfig
    var isVacationPeriod = false

    /// Remote Config에서 가져온 현재 테마 (noticeCheck 이후 호출)
    var currentTheme: String {
        return remoteConfig["app_theme"].stringValue ?? "default"
    }

    /// 축제 제휴(마커·도움말) 노출 여부. 행사 기간에만 Remote Config에서 켠다
    /// 구버전 앱이 쓰는 `festival_tab_enabled`와 분리해, 켜도 이전 버전 동작에 영향이 없도록 한다
    var isFestivalPartnershipEnabled: Bool {
        #if DEBUG
        // 로컬 확인용: 개발 빌드는 기본 노출. 스킴 실행 인자 `-festivalPartnershipDisabled YES`로 종료 후 동작도 확인할 수 있다
        return !UserDefaults.standard.bool(forKey: "festivalPartnershipDisabled")
        #else
        return remoteConfig["festival_partnership_enabled"].boolValue
        #endif
    }

    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()

        settings.minimumFetchInterval = 600
        remoteConfig.configSettings = settings
    }

    func noticeCheck(completion: @escaping (String?) -> Void) {
        #if DEBUG
        // 개발 환경에서는 Remote Config 체크 건너뛰기
        completion(nil)
        return
        #endif
        remoteConfig.fetch { [weak self] status, error in
            guard let self else { return }

            if status == .success {
                if let notice = activateRemoteConfig(), notice.dialog == true {
                    completion(notice.message)
                } else {
                    completion(nil)
                }
            } else {
                print("Error fetching remote config: \(error?.localizedDescription ?? "")")
                completion(nil)
            }
        }
    }

    private func activateRemoteConfig() -> NoticeMessage? {
        remoteConfig.activate()

        guard let json = remoteConfig["ios_message"].jsonValue else {
            print("Error: notice")
            return nil
        }

        let decoder = JSONDecoder()
        do {
            let value = try JSONSerialization.data(withJSONObject: json, options: [])
            let data = try decoder.decode(NoticeMessage.self, from: value)
            return data
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }

    func fetchRestaurantInfo() {
        // 1. fetch
        remoteConfig.fetch(withExpirationDuration: 0) { status, error in
            if status == .success {
                // 2. activate: 컨피그 값 가져옴
                self.remoteConfig.activate()

                let decoder = JSONDecoder()

                // cafeteria_information Parsing
                guard let cafeteriaRawValue = self.remoteConfig["cafeteria_information"].jsonValue else {
                    print("Error: cafeteria_information is nil")
                    return
                }
                do {
                    let cafeteriaJsonData = try JSONSerialization.data(withJSONObject: cafeteriaRawValue, options: [])
                    RestaurantInfoData.restaurantInfoData = try decoder.decode([RestaurantInfoData].self, from: cafeteriaJsonData)
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            } else {
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
    }

    func fetchIsVacationPeriod() {
        remoteConfig.fetch(withExpirationDuration: 0) { status, error in
            if status == .success {
                self.remoteConfig.activate()

                self.isVacationPeriod = self.remoteConfig["isVacationPeriod"].boolValue
                print("Is vacation period: \(self.isVacationPeriod)")
            } else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

}
