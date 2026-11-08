//
//  ReviewMenuTypeInfo.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/30.
//

import Foundation

struct ReviewMenuTypeInfo {
    var menuType: String
    var menuID: Int
    var changeMenuIDList: [Int]?
    var restaurantName: String?
    /// 리뷰 화면의 "오늘의 메뉴를 찜해보세요!" 판단용: 보고 있던 식단의 날짜·식당 코드(`HAKSIK` 등)·시간대(`LUNCH` 등)
    var date: Date?
    var restaurantCode: String?
    var timePart: String?
}
