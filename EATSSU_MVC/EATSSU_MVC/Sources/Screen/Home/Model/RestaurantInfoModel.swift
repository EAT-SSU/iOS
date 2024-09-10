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
    
    static func rawInfoData() -> [RestaurantInfoData] {
        return [RestaurantInfoData(name: "도담 식당", location: "신양관 2층", time: "", etc: "", image: ""),
                RestaurantInfoData(name: "학생 식당", location: "학생회관 3층", time: "", etc: "3개 코너 운영\n뚝배기찌개, 덮밥, 양식", image: ""),
                RestaurantInfoData(name: "스낵 코너", location: "학생회관 3층", time: "", etc: "분식류, 옛날도시락, 컵밥 등", image: ""),
                RestaurantInfoData(name: "푸드 코트", location: "학생회관 2층", time: "", etc: "아시안푸드, 돈까스, 샐러드, 국밥 등\n카페", image: ""),
                RestaurantInfoData(name: "기숙사 식당", location: "레지던스홀 지하 1층", time: "", etc: "주말 조식은 운영되지 않습니다.", image: "")
                ]
    }
}
