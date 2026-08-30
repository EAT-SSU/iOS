//
//  RestaurantInfoModel.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/16.
//

import UIKit

struct RestaurantInfoData: Codable {
    let name: String
    let location: String
    let time: String
    let etc: String
    let image: String
}

extension RestaurantInfoData {
    /// Firebase Remote Config `cafeteria_information`. fetch 성공 전에는 비어 있으며, 그동안은 strings 값이 표시된다
    static var restaurantInfoData: [RestaurantInfoData] = []

    /// Remote Config 원본 항목 (한국어 이름으로 매칭)
    static func remote(for restaurant: Restaurant) -> RestaurantInfoData? {
        restaurantInfoData.first { $0.name == restaurant.koreanName }
    }

    /// 현재 앱 언어로 표시할 식당 정보
    ///
    /// - 한국어: Remote Config 값을 우선 사용해 운영시간 등을 배포 없이 갱신할 수 있게 하고, 없으면 strings 값으로 폴백
    /// - 그 외 언어: Localizable.strings(다국어 스프레드시트) 값 사용
    /// - 이미지는 언어와 무관하게 Remote Config 값 사용
    static func localized(for restaurant: Restaurant) -> RestaurantInfoData {
        let remote = remote(for: restaurant)
        let isKorean = AppLanguageManager.shared.currentLanguage == .korean

        func text(_ remoteValue: String?, _ localized: String) -> String {
            let trimmed = remoteValue?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard isKorean, !trimmed.isEmpty else { return localized }
            return trimmed
        }

        let key = restaurant.rawValue
        return RestaurantInfoData(
            name: restaurant.title,
            location: text(remote?.location, TextLiteral.RestaurantInfo.location(restaurantKey: key)),
            time: text(remote?.time, TextLiteral.RestaurantInfo.time(restaurantKey: key)),
            etc: text(remote?.etc, TextLiteral.RestaurantInfo.etc(restaurantKey: key)),
            image: remote?.image ?? ""
        )
    }
}
