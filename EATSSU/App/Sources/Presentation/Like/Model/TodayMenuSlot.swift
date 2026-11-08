//
//  TodayMenuSlot.swift
//  EATSSU
//
//  Created by 황상환 on 11/8/26.
//

import Foundation

/// "오늘 식단에서 찜하기"에서 고른 식당·시간대
struct TodayMenuSlot: Equatable {
    let restaurant: Restaurant
    let mealTime: MealTimePart

    /// 찜 탭으로 들어왔을 때의 기본값 (기능 명세: 학생식당 · 점심)
    static let `default` = TodayMenuSlot(restaurant: .studentRestaurant, mealTime: .lunch)

    /// 바텀시트에서 고를 수 있는 식당. 스낵코너는 메뉴가 고정이라 찜 대상이 아니다 (디자인 기준 4곳)
    static let selectableRestaurants: [Restaurant] = [
        .studentRestaurant, .dodamRestaurant, .dormitoryRestaurant, .facultyRestaurant
    ]

    /// 식당마다 운영하지 않는 시간대가 있다 (기능 명세)
    /// 학생식당 저녁 미운영 · 도담식당 아침 미운영 · 기숙사식당 아침 미운영 · 교직원식당 아침·저녁 미운영
    static func isAvailable(restaurant: Restaurant, mealTime: MealTimePart) -> Bool {
        switch restaurant {
        case .studentRestaurant: mealTime != .dinner
        case .dodamRestaurant, .dormitoryRestaurant: mealTime != .morning
        case .facultyRestaurant, .snackCorner: mealTime == .lunch
        }
    }

    var isAvailable: Bool {
        Self.isAvailable(restaurant: restaurant, mealTime: mealTime)
    }

    /// 리뷰 화면 "오늘의 메뉴를 찜해보세요!"에 연결할 식당·시간대
    ///
    /// 변동 식단(`VARIABLE`)이고, 식단 날짜가 오늘이며, 찜 대상 식당(스낵코너 제외)일 때만 값이 있다.
    /// 어제·내일 식단에서는 버튼을 보여주지 않는다 (기능 명세)
    static func forReview(menuType: String, restaurantCode: String?, timePart: String?, date: Date?, now: Date = Date()) -> TodayMenuSlot? {
        guard menuType == "VARIABLE",
              let date, Calendar.current.isDate(date, inSameDayAs: now),
              let restaurant = Restaurant.allCases.first(where: { $0.identifier == restaurantCode }),
              selectableRestaurants.contains(restaurant),
              let mealTime = timePart.flatMap(MealTimePart.init(rawValue:)) else { return nil }
        return TodayMenuSlot(restaurant: restaurant, mealTime: mealTime)
    }

    /// "학생 식당 · 점심"
    var title: String {
        "\(restaurant.shortTitle) · \(mealTime.title)"
    }
}
