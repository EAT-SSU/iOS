//
//  NotificationDTO.swift
//  EATSSU
//
//  Created by 황상환 on 11/7/26.
//

import Foundation

/// 알림함 항목 (`GET /notifications`)
struct NotificationItemDTO: Codable, Equatable {
    let notificationId: Int
    /// 알림 종류. 현재는 `MENU_FAVORITE`만 온다
    let type: String
    /// 제목·본문은 조회 시점의 사용자 언어로 만들어진다
    let title: String
    let body: String
    /// 알림을 누르면 이동할 식단 날짜 (yyyyMMdd)
    let date: String
    /// 이동할 시간대 (MORNING / LUNCH / DINNER)
    let timePart: String?
    let isRead: Bool
    /// 알림 생성 시각. 서버(한국) 시간이며 타임존 표기가 없다 (예: `2026-11-02T11:00:00`)
    let createdAt: String
}

/// `GET /notifications/unread`
struct UnreadNotificationDTO: Codable {
    let hasUnread: Bool
}
