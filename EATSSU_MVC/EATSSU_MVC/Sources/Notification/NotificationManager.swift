//
//  NotificationManager.swift
//  EATSSU
//
//  Created by Jiwoong CHOI on 9/10/24.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
  /// 지정된 시간에 알림을 발송하는 메소드
    func scheduleHelloWorldNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Hello World"
        content.body = "11시가 되었습니다!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 11
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "helloWorldNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Hello World 알림 예약 실패: \(error.localizedDescription)")
            } else {
                print("Hello World 알림이 성공적으로 예약되었습니다.")
            }
        }
    }
    
  /// 앱 실행 시 알림 발송 권한을 요청하는 팝업 호출 메소드
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("알림 권한 승인됨")
            } else {
                print("알림 권한 거부됨")
            }
        }
    }
  
  /// 개발자 도구 : 시뮬레이터에서 지속적으로 알림을 확인하기 위한 메소드
  ///
  /// 해당 메소드는 배포 시 호출되면 안됩니다.
  func scheduleTestNotification() {
      let content = UNMutableNotificationContent()
      content.title = "Hello World"
      content.body = "테스트 알림입니다!"
      content.sound = .default
      
      // 3초 후에 알림 발생
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
      
      let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)
      
      UNUserNotificationCenter.current().add(request) { error in
          if let error = error {
              print("테스트 알림 예약 실패: \(error.localizedDescription)")
          } else {
              print("테스트 알림이 성공적으로 예약되었습니다.")
          }
      }
  }
}
