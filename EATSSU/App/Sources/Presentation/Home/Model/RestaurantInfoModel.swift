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
    static var restaurantInfoData = rawInfoData()

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
            guard isKorean, let remoteValue, !remoteValue.isEmpty else { return localized }
            return remoteValue
        }

        return RestaurantInfoData(
            name: restaurant.title,
            location: text(remote?.location, TextLiteral.RestaurantInfo.location(restaurant)),
            time: text(remote?.time, TextLiteral.RestaurantInfo.time(restaurant)),
            etc: text(remote?.etc, TextLiteral.RestaurantInfo.etc(restaurant)),
            image: remote?.image ?? ""
        )
    }

    static func rawInfoData() -> [RestaurantInfoData] {
        [RestaurantInfoData(name: "도담 식당", location: "신양관 2층", time: "", etc: "", image: ""),
         RestaurantInfoData(name: "학생 식당", location: "학생회관 3층", time: "", etc: "3개 코너 운영\n뚝배기찌개, 덮밥, 양식", image: ""),
         RestaurantInfoData(name: "스낵 코너", location: "학생회관 3층", time: "", etc: "분식류, 옛날도시락, 컵밥 등", image: ""),
         RestaurantInfoData(name: "기숙사 식당", location: "레지던스홀 지하 1층", time: "", etc: "주말 조식은 운영되지 않습니다.", image: ""),
         RestaurantInfoData(name: "FACULTY (교직원 전용)", location: "전산관 지하 1층", time: "11:20~14:00", etc: "주말은 운영되지 않습니다.", image: ""),
        ]
    }
}
