//
//  ESEntry.swift
//  EATSSU_MVC
//
//  Created by JIWOONG CHOI on 12/31/24.
//

import WidgetKit

struct ESEntry: TimelineEntry {
    let date: Date
    let restaurantName: String
    let menus: [String]

    init(date: Date, restaurantName: String, menus: [String] = ["메뉴가 없습니다."]) {
        self.date = date
        self.restaurantName = restaurantName
        self.menus = menus
    }
}
