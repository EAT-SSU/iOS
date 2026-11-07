//
//  NotificationInboxService.swift
//  EATSSU
//
//  Created by 황상환 on 11/7/26.
//

import Foundation

/// 알림함 API 호출 모음. 알림함 화면, 학식 탭 알림 아이콘, 푸시 탭 읽음 처리가 함께 쓴다
enum NotificationInboxService {

    static func fetchNotifications(completion: @escaping (Result<[NotificationItemDTO], Error>) -> Void) {
        NetworkService.shared.request(
            NotificationRouter.getNotifications,
            responseType: [NotificationItemDTO].self,
            useAuth: true,
            completion: completion
        )
    }

    static func fetchHasUnread(completion: @escaping (Result<Bool, Error>) -> Void) {
        NetworkService.shared.request(
            NotificationRouter.hasUnread,
            responseType: UnreadNotificationDTO.self,
            useAuth: true
        ) { result in
            completion(result.map { $0.hasUnread })
        }
    }

    /// 읽음 처리 뒤 `.didUpdateNotificationReadState`를 보내 학식 탭 알림 아이콘이 점을 갱신하게 한다
    static func markRead(notificationId: Int, completion: ((Result<Bool, Error>) -> Void)? = nil) {
        NetworkService.shared.request(
            NotificationRouter.read(notificationId: notificationId),
            responseType: Bool.self,
            useAuth: true
        ) { result in
            if case .success = result {
                NotificationCenter.default.post(name: .didUpdateNotificationReadState, object: nil)
            }
            completion?(result)
        }
    }

    static func markAllRead(completion: @escaping (Result<Bool, Error>) -> Void) {
        NetworkService.shared.request(
            NotificationRouter.readAll,
            responseType: Bool.self,
            useAuth: true
        ) { result in
            if case .success = result {
                NotificationCenter.default.post(name: .didUpdateNotificationReadState, object: nil)
            }
            completion(result)
        }
    }
}
