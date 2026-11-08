//
//  NotificationTimeDisplayTests.swift
//  EATSSUUnitTests
//
//  Created by 황상환 on 11/7/26.
//

import XCTest

@testable import EATSSU_DEV

/// 알림함 시각 표시 규칙: 하루 미만 "n시간 전", 하루 이상 "n월 n일"
final class NotificationTimeDisplayTests: XCTestCase {

    private let korean = Locale(identifier: "ko")

    /// 한국 시간 2026-07-27 12:00
    private let now: Date = {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone(identifier: "Asia/Seoul")
        components.year = 2026; components.month = 7; components.day = 27; components.hour = 12
        return components.date!
    }()

    func test_한_시간_미만은_방금_전() {
        XCTAssertEqual(NotificationTimeDisplay.make(createdAt: "2026-07-27T11:30:00", now: now, locale: korean), .justNow)
    }

    func test_하루_미만은_시간_단위로_내림() {
        XCTAssertEqual(NotificationTimeDisplay.make(createdAt: "2026-07-27T11:00:00", now: now, locale: korean), .hoursAgo(1))
        XCTAssertEqual(NotificationTimeDisplay.make(createdAt: "2026-07-26T12:30:00", now: now, locale: korean), .hoursAgo(23))
    }

    func test_하루_이상은_앱_언어의_월일로_표시() {
        XCTAssertEqual(NotificationTimeDisplay.make(createdAt: "2026-07-26T11:00:00", now: now, locale: korean), .date("7월 26일"))
        XCTAssertEqual(NotificationTimeDisplay.make(createdAt: "2026-07-22T11:00:00", now: now, locale: Locale(identifier: "en")), .date("Jul 22"))
        XCTAssertEqual(NotificationTimeDisplay.make(createdAt: "2026-07-22T11:00:00", now: now, locale: Locale(identifier: "ja")), .date("7月22日"))
    }

    func test_소수점_초가_붙어도_읽고_형식이_다르면_nil() {
        XCTAssertEqual(NotificationTimeDisplay.make(createdAt: "2026-07-27T11:30:00.123456", now: now, locale: korean), .justNow)
        XCTAssertNil(NotificationTimeDisplay.make(createdAt: "2026-07-27 11:30", now: now, locale: korean))
    }
}
