//
//  HomeAnalyticsManager.swift
//  EATSSU
//
//  Created by 황상환 on 8/24/25.
//

import Foundation

/// 홈 화면에서 발생하는 주요 이벤트를 Firebase Analytics에 로깅하는 담당자
final class HomeAnalyticsManager {

    // MARK: - Singleton

    static let shared = HomeAnalyticsManager()
    private init() {}

    // MARK: - Event & Parameter Keys

    private enum Event {
        static let clickRestaurantInfo = "click_restaurant_info"
        static let selectMealTime = "select_mealtime"
        static let selectDay = "click_day"
        static let clickMenu = "click_menu"
    }

    private enum Parameter {
        static let restaurants = "restaurants"
        static let mealTime = "mealtime"
        static let day = "day"
    }

    // MARK: - Mappers

    // 식당 이름(한글) -> 영문 소문자 파라미터로 변환
    private let restaurantNameMap: [String: String] = [
        TextLiteral.Restaurant.studentRestaurant: "haksik",
        TextLiteral.Restaurant.dodamRestaurant: "dodam",
        TextLiteral.Restaurant.dormitoryRestaurant: "dormitory",
        TextLiteral.Restaurant.facultyRestaurant: "faculty"
    ]

    // 식사 유형(한글) -> 영문 소문자 파라미터로 변환
    private let mealTimeMap: [String: String] = [
        TextLiteral.Home.morning: "breakfast",
        TextLiteral.Home.lunch: "lunch",
        TextLiteral.Home.dinner: "dinner"
    ]

    // Date 객체 -> 요일(영문 소문자) 문자열로 변환
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "eee"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()

    // MARK: - Logging Methods

    /**
     #1 식당 정보 아이콘(ⓘ)을 클릭했을 때 호출
     - Parameter restaurantName: 사용자가 클릭한 식당의 이름 (예: "학생 식당")
     */
    func logClickRestaurantInfo(restaurantName: String) {
        guard let parameterValue = restaurantNameMap[restaurantName] else {
            print("Analytics Error: Invalid restaurant name for click_restaurant_info - \(restaurantName)")
            return
        }

        AnalyticsService.logEvent(Event.clickRestaurantInfo, parameters: [
            Parameter.restaurants: parameterValue
        ])
    }

    /**
     #2 식사 유형(아침, 점심, 저녁) 탭을 변경했을 때 호출
     - Parameter mealTime: 사용자가 선택한 식사 유형 (예: "아침")
     */
    func logSelectMealTime(mealTime: String) {
        guard let parameterValue = mealTimeMap[mealTime] else {
            print("Analytics Error: Invalid meal time for select_mealtime - \(mealTime)")
            return
        }

        AnalyticsService.logEvent(Event.selectMealTime, parameters: [
            Parameter.mealTime: parameterValue
        ])
    }

    /**
     #3 요일(날짜)을 변경했을 때 호출
     - Parameter date: 사용자가 선택한 날짜 (Date 객체)
     */
    func logSelectDay(date: Date) {
        let parameterValue = dayFormatter.string(from: date).lowercased()

        AnalyticsService.logEvent(Event.selectDay, parameters: [
            Parameter.day: parameterValue
        ])
    }

    /**
     #4 메뉴를 클릭하여 리뷰 화면으로 넘어갈 때 호출
     - Parameter restaurantName: 사용자가 클릭한 메뉴가 속한 식당의 이름 (예: "학생 식당")
     */
    func logClickMenu(restaurantName: String) {
        guard let parameterValue = restaurantNameMap[restaurantName] else {
            print("Analytics Error: Invalid restaurant name for click_menu - \(restaurantName)")
            return
        }

        AnalyticsService.logEvent(Event.clickMenu, parameters: [
            Parameter.restaurants: parameterValue
        ])
    }
}
