//
//  Weekday.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 11/18/23.
//

import Foundation

enum Weekday: Int {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday

    static func from(date: Date) -> Weekday {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: date)
        return Weekday(rawValue: weekdayNumber)!
    }

    var isWeekend: Bool {
        return self == .saturday || self == .sunday
    }
}
