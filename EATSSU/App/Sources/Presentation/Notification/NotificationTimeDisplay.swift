//
//  NotificationTimeDisplay.swift
//  EATSSU
//
//  Created by 황상환 on 11/7/26.
//

import Foundation

/// 알림 생성 시각 표시 규칙. 하루가 안 지난 알림은 "n시간 전", 하루가 지난 알림은 "n월 n일"
enum NotificationTimeDisplay: Equatable {
    /// 1시간 미만
    case justNow
    /// 1시간 이상 24시간 미만
    case hoursAgo(Int)
    /// 24시간 이상. 앱 언어로 "7월 26일" 형태
    case date(String)

    /// - Parameters:
    ///   - createdAt: 서버 `createdAt` (`yyyy-MM-dd'T'HH:mm:ss`, 한국 시간, 타임존 표기 없음)
    ///   - now: 비교 기준 시각
    ///   - locale: 날짜 표기 언어
    /// - Returns: 파싱에 실패하면 nil
    static func make(createdAt: String, now: Date = Date(), locale: Locale) -> NotificationTimeDisplay? {
        guard let created = Self.parse(createdAt) else { return nil }
        let elapsed = now.timeIntervalSince(created)
        if elapsed < 3600 {
            return .justNow
        }
        if elapsed < 24 * 3600 {
            return .hoursAgo(Int(elapsed / 3600))
        }
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = Self.serverTimeZone
        formatter.setLocalizedDateFormatFromTemplate("MMMd")
        return .date(formatter.string(from: created))
    }

    /// 서버는 한국 시간을 타임존 없이 내려주므로 한국 시간으로 해석한다
    private static let serverTimeZone = TimeZone(identifier: "Asia/Seoul") ?? .current

    private static let parser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = serverTimeZone
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()

    private static func parse(_ string: String) -> Date? {
        // 소수점 초(`11:00:00.123`)가 붙어 와도 읽을 수 있게 잘라낸다
        let trimmed = string.split(separator: ".", maxSplits: 1).first.map(String.init) ?? string
        return parser.date(from: trimmed)
    }
}
