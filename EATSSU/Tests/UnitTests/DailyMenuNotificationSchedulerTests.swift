//
//  DailyMenuNotificationSchedulerTests.swift
//  EATSSUUnitTests
//
//  Created by 황상환 on 11/9/26.
//

import XCTest
import UserNotifications

@testable import EATSSU_DEV

/// 평일 11시 로컬 알림의 예약 조건·식별자 규칙 검증
final class DailyMenuNotificationSchedulerTests: XCTestCase {

    /// 찜 알림 수신 날짜는 실제 UserDefaults에 저장되므로 테스트 전 값을 보관했다가 되돌린다
    private let favoritePushReceivedDayKey = DailyMenuNotificationScheduler.favoritePushReceivedDayKey
    private var savedFavoritePushReceivedDay: String?

    override func setUp() {
        super.setUp()
        savedFavoritePushReceivedDay = UserDefaults.standard.string(forKey: favoritePushReceivedDayKey)
    }

    override func tearDown() {
        if let savedFavoritePushReceivedDay {
            UserDefaults.standard.set(savedFavoritePushReceivedDay, forKey: favoritePushReceivedDayKey)
        } else {
            UserDefaults.standard.removeObject(forKey: favoritePushReceivedDayKey)
        }
        super.tearDown()
    }

    func test_토글이_켜져_있고_권한이_허용돼야_알림을_보낸다() {
        XCTAssertTrue(NotificationManager.isNotificationAllowed(authorization: .authorized, isToggleOn: true))
        XCTAssertTrue(NotificationManager.isNotificationAllowed(authorization: .provisional, isToggleOn: true))
        XCTAssertFalse(NotificationManager.isNotificationAllowed(authorization: .authorized, isToggleOn: false))
        XCTAssertFalse(NotificationManager.isNotificationAllowed(authorization: .denied, isToggleOn: true))
        XCTAssertFalse(NotificationManager.isNotificationAllowed(authorization: .notDetermined, isToggleOn: true))
    }

    func test_월요일부터_금요일까지_하나씩_예약한다() {
        XCTAssertEqual(DailyMenuNotificationScheduler.weekdays, [2, 3, 4, 5, 6])
        XCTAssertEqual(DailyMenuNotificationScheduler.hour, 11)
    }

    func test_식별자는_요일로_구분되고_접두사로_판별한다() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "Asia/Seoul"))
        // 2026-11-09 월요일
        let monday = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 11, day: 9, hour: 11)))
        let identifier = DailyMenuNotificationScheduler.identifier(for: monday, calendar: calendar)
        XCTAssertEqual(identifier, "weekdayNotification-2")
        XCTAssertTrue(DailyMenuNotificationScheduler.isDailyMenuNotification(identifier: identifier))
        XCTAssertFalse(DailyMenuNotificationScheduler.isDailyMenuNotification(identifier: "menuFavorite-20261109"))
    }

    func test_같은_날_찜_알림을_받았으면_로컬_알림을_띄우지_않는다() throws {
        let today = Date()
        let yesterday = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -1, to: today))
        DailyMenuNotificationScheduler.didReceiveFavoritePush(on: yesterday)
        XCTAssertTrue(DailyMenuNotificationScheduler.shouldPresent(dailyNotificationOn: today))
        DailyMenuNotificationScheduler.didReceiveFavoritePush(on: today)
        XCTAssertFalse(DailyMenuNotificationScheduler.shouldPresent(dailyNotificationOn: today))
    }
}
