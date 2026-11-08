//
//  TodayMenuSlotTests.swift
//  EATSSUUnitTests
//
//  Created by 황상환 on 11/8/26.
//

import XCTest

@testable import EATSSU_DEV

/// "오늘 식단에서 찜하기" 식당·시간대 규칙 (기능 명세)
final class TodayMenuSlotTests: XCTestCase {

    func test_기본값은_학생식당_점심() {
        XCTAssertEqual(TodayMenuSlot.default, TodayMenuSlot(restaurant: .studentRestaurant, mealTime: .lunch))
    }

    func test_고를_수_있는_식당은_4곳이고_스낵코너는_없다() {
        XCTAssertEqual(TodayMenuSlot.selectableRestaurants.count, 4)
        XCTAssertFalse(TodayMenuSlot.selectableRestaurants.contains(.snackCorner))
    }

    func test_식당별_미운영_시간대() {
        XCTAssertFalse(TodayMenuSlot.isAvailable(restaurant: .studentRestaurant, mealTime: .dinner))
        XCTAssertTrue(TodayMenuSlot.isAvailable(restaurant: .studentRestaurant, mealTime: .morning))
        XCTAssertFalse(TodayMenuSlot.isAvailable(restaurant: .dodamRestaurant, mealTime: .morning))
        XCTAssertTrue(TodayMenuSlot.isAvailable(restaurant: .dodamRestaurant, mealTime: .dinner))
        XCTAssertFalse(TodayMenuSlot.isAvailable(restaurant: .dormitoryRestaurant, mealTime: .morning))
        XCTAssertFalse(TodayMenuSlot.isAvailable(restaurant: .facultyRestaurant, mealTime: .morning))
        XCTAssertFalse(TodayMenuSlot.isAvailable(restaurant: .facultyRestaurant, mealTime: .dinner))
        XCTAssertTrue(TodayMenuSlot.isAvailable(restaurant: .facultyRestaurant, mealTime: .lunch))
    }

    func test_시간대_탭_인덱스와_서버_값() {
        XCTAssertEqual(MealTimePart(rawValue: "LUNCH")?.tabIndex, 1)
        XCTAssertEqual(MealTimePart.allCases.map(\.tabIndex), [0, 1, 2])
    }
}
