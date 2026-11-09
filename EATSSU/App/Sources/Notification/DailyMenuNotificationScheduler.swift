//
//  DailyMenuNotificationScheduler.swift
//  EATSSU
//
//  Created by 황상환 on 11/9/26.
//

import Foundation
import UserNotifications

/// 평일 11시 "오늘 밥 뭐 먹지…" 로컬 알림
///
/// 찜 알림은 서버가 찜한 메뉴가 나온 사용자에게만 푸시로 보내고, 그 외 사용자에게 가는 일반 학식 알림은
/// 서버 범위가 아니어서 앱이 로컬 알림으로 보낸다. "마이페이지 알림 ON + 기기 알림 권한 허용"일 때만 예약하고,
/// 그 외에는 취소한다. 서버 알림함에는 남지 않는다
enum DailyMenuNotificationScheduler {

    // MARK: - Constants

    /// 알림 식별자 접두사. 요일별로 하나씩 예약한다 (`weekdayNotification-2` … `-6`)
    static let identifierPrefix = "weekdayNotification-"

    /// 월~금 (`Calendar.weekday`: 1이 일요일)
    static let weekdays = [2, 3, 4, 5, 6]

    static let hour = 11

    /// 당일 찜 알림(서버 푸시)을 받은 날짜(yyyyMMdd). 같은 날 로컬 알림은 띄우지 않는다
    private static let favoritePushReceivedDayKey = "dailyMenuNotification.favoritePushReceivedDay"

    // MARK: - Decision

    static func identifier(weekday: Int) -> String {
        "\(identifierPrefix)\(weekday)"
    }

    /// 주어진 시각이 속한 요일의 알림 식별자
    static func identifier(for date: Date, calendar: Calendar = .current) -> String {
        identifier(weekday: calendar.component(.weekday, from: date))
    }

    static func isDailyMenuNotification(identifier: String) -> Bool {
        identifier.hasPrefix(identifierPrefix)
    }

    /// 예약 조건: 마이페이지 알림 토글 ON + 기기 권한 허용
    static func shouldSchedule(authorization: UNAuthorizationStatus, isToggleOn: Bool) -> Bool {
        guard isToggleOn else { return false }
        switch authorization {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied, .notDetermined:
            return false
        @unknown default:
            return false
        }
    }

    // MARK: - Sync

    /// 현재 토글·권한 상태에 맞게 예약하거나 취소한다
    /// 호출 시점: 앱 실행, 알림 권한 결과, 마이페이지 알림 토글 변경, 언어 변경(문구 갱신)
    static func sync() {
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            let isToggleOn = UserDefaults.standard.bool(forKey: TextLiteral.MyPage.pushNotificationUserSettingKey)
            if shouldSchedule(authorization: settings.authorizationStatus, isToggleOn: isToggleOn) {
                await schedule()
            } else {
                cancel()
            }
        }
    }

    /// 월~금 11시에 반복되는 알림을 등록한다. 같은 식별자로 다시 등록하면 덮어쓰므로(언어 변경 등) 취소 없이 호출해도 된다
    private static func schedule() async {
        let center = UNUserNotificationCenter.current()
        for weekday in weekdays {
            let content = UNMutableNotificationContent()
            content.title = TextLiteral.Notification.dailyWeekdayNotificationTitle
            content.body = TextLiteral.Notification.dailyWeekdayNotificationBody
            content.sound = .default

            var components = DateComponents()
            components.weekday = weekday
            components.hour = hour
            components.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

            let request = UNNotificationRequest(identifier: identifier(weekday: weekday), content: content, trigger: trigger)
            do {
                try await center.add(request)
            } catch {
                print("11시 학식 알림 예약 실패: \(error.localizedDescription)")
            }
        }
    }

    static func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: weekdays.map(identifier(weekday:)))
    }

    // MARK: - 찜 알림과 중복 제거

    /// 찜 알림(서버 푸시)을 받았을 때 호출. 같은 날 이미 떠 있는 로컬 알림을 알림 센터에서 지우고,
    /// 아직 안 떴다면 `shouldPresent`가 거르도록 날짜를 기억한다
    ///
    /// 앱이 백그라운드에 있고 사용자가 푸시를 누르지 않으면 이 코드가 실행되지 않아 두 알림이 함께 남을 수 있다
    static func didReceiveFavoritePush(on date: Date = Date()) {
        UserDefaults.standard.set(DateFormatter.serverDay.string(from: date), forKey: favoritePushReceivedDayKey)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier(for: date)])
    }

    /// 앱 사용 중 로컬 알림이 도착했을 때 띄울지. 같은 날 찜 알림을 이미 받았으면 띄우지 않는다
    static func shouldPresent(dailyNotificationOn date: Date = Date()) -> Bool {
        UserDefaults.standard.string(forKey: favoritePushReceivedDayKey) != DateFormatter.serverDay.string(from: date)
    }
}
