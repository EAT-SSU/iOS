//
//  PushRouteTests.swift
//  EATSSUUnitTests
//
//  Created by 황상환 on 10/17/26.
//

import XCTest

@testable import EATSSU_DEV

/// 서버 푸시 data → 학식 화면 이동 정보 해석 검증
final class PushRouteTests: XCTestCase {

    private func components(of date: Date) -> DateComponents {
        Calendar(identifier: .gregorian).dateComponents([.year, .month, .day], from: date)
    }

    func test_찜_알림은_날짜와_시간대를_읽는다() throws {
        let route = try XCTUnwrap(PushRoute(userInfo: ["type": "MENU_FAVORITE", "date": "20261005", "timePart": "DINNER"]))
        let date = components(of: route.date)
        XCTAssertEqual([date.year, date.month, date.day], [2026, 10, 5])
        XCTAssertEqual(route.mealTime, .dinner)
        XCTAssertEqual(route.mealTime?.tabIndex, 2)
    }

    func test_일반_학식_알림은_시간대_없이_날짜만_읽는다() throws {
        let route = try XCTUnwrap(PushRoute(userInfo: ["type": "DAILY_MENU", "date": "20261017"]))
        XCTAssertNil(route.mealTime)
    }

    func test_알_수_없는_타입이나_잘못된_날짜는_무시한다() {
        XCTAssertNil(PushRoute(userInfo: ["type": "PROMOTION", "date": "20261005"]))
        XCTAssertNil(PushRoute(userInfo: ["type": "MENU_FAVORITE", "date": "2026-10-05"]))
        XCTAssertNil(PushRoute(userInfo: ["type": "MENU_FAVORITE"]))
        XCTAssertNil(PushRoute(userInfo: [:]))
    }

    func test_시간대_값이_이상하면_시간대만_비운다() throws {
        let route = try XCTUnwrap(PushRoute(userInfo: ["type": "MENU_FAVORITE", "date": "20261005", "timePart": "BRUNCH"]))
        XCTAssertNil(route.mealTime)
    }
}
