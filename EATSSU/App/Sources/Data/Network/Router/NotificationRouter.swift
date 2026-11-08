//
//  NotificationRouter.swift
//  EATSSU
//
//  Created by 황상환 on 11/7/26.
//

import Foundation

import Moya

/// 알림함 API (로그인 필요). 서버는 최근 7일(식단 날짜 기준) 찜 메뉴 알림만 보관한다
enum NotificationRouter {
    /// 알림 목록 (최신순). 제목·본문은 조회 시점의 사용자 언어로 내려온다
    case getNotifications
    /// 안 읽은 알림이 있는지 (학식 탭 알림 아이콘의 점 표시)
    case hasUnread
    /// 알림 하나 읽음 처리. 이미 읽었어도 성공
    case read(notificationId: Int)
    /// 내 알림 모두 읽음 처리
    case readAll
}

extension NotificationRouter: TargetType {
    var baseURL: URL {
        URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .getNotifications:
            "/notifications"
        case .hasUnread:
            "/notifications/unread"
        case let .read(notificationId):
            "/notifications/\(notificationId)/read"
        case .readAll:
            "/notifications/read-all"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getNotifications, .hasUnread:
            .get
        case .read, .readAll:
            .patch
        }
    }

    var task: Moya.Task {
        .requestPlain
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }

    var validationType: ValidationType {
        .successCodes
    }
}
