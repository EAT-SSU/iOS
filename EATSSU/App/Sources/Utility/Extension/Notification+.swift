//
//  Notification.swift
//  EATSSU
//
//  Created by 한금준 on 6/23/25.
//

import Foundation

extension Notification.Name {
    static let didEnterNewDay = Notification.Name("didEnterNewDay")
    /// 앱 사용 중(포그라운드)에 푸시가 도착함. 학식 탭 알림 아이콘이 안 읽은 알림 여부를 다시 확인한다
    static let didReceivePushNotification = Notification.Name("didReceivePushNotification")
    /// 알림을 읽음 처리함 (알림함·모두 읽음·푸시 탭). 학식 탭 알림 아이콘이 점을 갱신한다
    static let didUpdateNotificationReadState = Notification.Name("didUpdateNotificationReadState")
    // 추가 알림 이름도 여기 모아서 관리
}
