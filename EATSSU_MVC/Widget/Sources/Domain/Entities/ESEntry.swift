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
    let menu: String

    init(date: Date, restaurantName: String, menu: String = "No menu available") {
        self.date = date
        self.restaurantName = restaurantName
        self.menu = menu
    }
}
