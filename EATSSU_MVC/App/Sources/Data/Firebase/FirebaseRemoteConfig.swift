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

    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()

        settings.minimumFetchInterval = 600
        remoteConfig.configSettings = settings
    }

    func noticeCheck(completion: @escaping (String?) -> Void) {
        remoteConfig.fetch { [weak self] status, error in
            guard let self = self else { return }

            if status == .success {
                if let notice = self.activateRemoteConfig(), notice.dialog == true {
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
