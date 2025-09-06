//
//  HomeAnalyticsManager.swift
//  EATSSU
//
//  Created by 황상환 on 8/24/25.
//

import Foundation
import FirebaseAnalytics

/// 홈 화면에서 발생하는 주요 이벤트를 Firebase Analytics에 로깅하는 담당자
final class HomeAnalyticsManager {
    
    // MARK: - Singleton
    
    static let shared = HomeAnalyticsManager()
    private init() {}
    
    // MARK: - Event & Parameter Keys
    
    private enum Event {
        static let clickCafeteriaInfo = "click_cafeteria_info"
        static let selectMealType = "select_mealtype"
        static let selectDay = "select_day"
        static let clickMenu = "click_menu"
    }
    
    private enum Parameter {
        static let restaurants = "restaurants"
        static let mealType = "mealtype"
        static let day = "day"
    }
    
    // MARK: - Mappers
    
    // 화면에 표시되는 식당 이름(한글)을 애널리틱스 파라미터 값(영문 소문자)으로 변환
    private let restaurantNameMap: [String: String] = [
        TextLiteral.studentRestaurant: "haksik",
        TextLiteral.dodamRestaurant: "dodam",
        TextLiteral.dormitoryRestaurant: "dorm",
        TextLiteral.facultyRestaurant: "faculty",
        TextLiteral.snackCorner: "snack_bar"
    ]
    
    // 식사 유형 탭 이름(한글)을 애널리틱스 파라미터 값(영문 소문자)으로 변환
    private let mealTypeMap: [String: String] = [
        TextLiteral.morning: "breakfast",
        TextLiteral.lunch: "lunch",
        TextLiteral.dinner: "diner"
    ]
    
    // 날짜를 요일 파라미터 값(영문 소문자)으로 변환하기 위한 Formatter
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
    func logClickCafeteriaInfo(restaurantName: String) {
        guard let parameterValue = restaurantNameMap[restaurantName] else {
            print("Analytics Error: Invalid restaurant name for click_cafeteria_info - \(restaurantName)")
            return
        }
        
        Analytics.logEvent(Event.clickCafeteriaInfo, parameters: [
            Parameter.restaurants: parameterValue
        ])
    }
    
    /**
     #2 식사 유형(아침, 점심, 저녁) 탭을 변경했을 때 호출
     - Parameter mealType: 사용자가 선택한 식사 유형 (예: "아침")
     */
    func logSelectMealType(mealType: String) {
        guard let parameterValue = mealTypeMap[mealType] else {
            print("Analytics Error: Invalid meal type for select_mealtype - \(mealType)")
            return
        }
        
        Analytics.logEvent(Event.selectMealType, parameters: [
            Parameter.mealType: parameterValue
        ])
    }
    
    /**
     #3 요일(날짜)을 변경했을 때 호출
     - Parameter date: 사용자가 선택한 날짜 (Date 객체)
     */
    func logSelectDay(date: Date) {
        let parameterValue = dayFormatter.string(from: date).lowercased()
        
        Analytics.logEvent(Event.selectDay, parameters: [
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

        Analytics.logEvent(Event.clickMenu, parameters: [
            Parameter.restaurants: parameterValue
        ])
    }
}
