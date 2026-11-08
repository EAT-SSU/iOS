//
//  MealTimePart.swift
//  EATSSU
//
//  Created by 황상환 on 11/8/26.
//

import Foundation

/// 학식 시간대. rawValue는 서버 `timePart` 값이며 학식 탭 순서(아침·점심·저녁)와 같다
enum MealTimePart: String, CaseIterable {
    case morning = "MORNING"
    case lunch = "LUNCH"
    case dinner = "DINNER"

    /// 학식 탭의 시간대 탭 인덱스
    var tabIndex: Int {
        switch self {
        case .morning: 0
        case .lunch: 1
        case .dinner: 2
        }
    }

    /// 현재 앱 언어의 시간대 이름
    var title: String {
        switch self {
        case .morning: TextLiteral.Home.morning
        case .lunch: TextLiteral.Home.lunch
        case .dinner: TextLiteral.Home.dinner
        }
    }
}
