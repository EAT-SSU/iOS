//
//  LaunchSourceManager.swift
//  EATSSU
//
//  Created by 황상환 on 3/23/25.
//

import Foundation
import UIKit
import FirebaseAnalytics

enum LaunchSource: String {
    case icon = "icon"
    case localNotification = "local_notification"
    case widget = "widget"
}

class LaunchSourceManager {
    static let shared = LaunchSourceManager()
    
    private(set) var source: LaunchSource = .icon
    private var hasLogged = false
    private var backgroundEntryTime: Date?
    private let newSessionThreshold: TimeInterval = 300
    
    private init() {}
    
    /// 앱 실행 소스를 설정합니다
    /// - Parameter source: 설정할 실행 소스
    func setSource(_ source: LaunchSource) {
        print("소스 설정 시도: \(source.rawValue) (현재 소스: \(self.source.rawValue), 로깅 상태: \(hasLogged))")
        
        // 로컬 알림 소스 설정은 항상 우선시
        if source == .localNotification {
            let changed = self.source != source
            self.source = source
            
            // 소스가 변경되었으면 로깅 상태 초기화
            if changed {
                hasLogged = false
            }
            return
        }
        
        // 위젯 소스 설정도 항상 우선시
        if source == .widget {
            let changed = self.source != source
            self.source = source
            
            if changed {
                hasLogged = false
            }
            return
        }
        
        // 아이콘 소스는 기존 소스가 없을 때만 설정
        if source == .icon && self.source == .icon {
            // 이미 아이콘으로 설정되어 있으면 변경 없음
            return
        }
    }
    
    /// 앱이 백그라운드로 갈 때 호출
    func appDidEnterBackground() {
        backgroundEntryTime = Date()
    }
    
    /// 새 세션인지 체크 - 앱이 백그라운드에서 일정 시간 이상 있었는지 확인
    /// - Returns: 새 세션 여부
    func checkNewSession() -> Bool {
        // 백그라운드 시간이 없으면 콜드 스타트(앱이 완전히 종료된 후 실행)로 간주
        guard let backgroundTime = backgroundEntryTime else { return true }
        
        let timeDifference = Date().timeIntervalSince(backgroundTime)
        return timeDifference >= newSessionThreshold
    }
    
    /// 필요시 Firebase Analytics에 앱 실행 이벤트 로깅
    func logIfNeeded() {
        // 콜드 스타트이거나 백그라운드에서 오래 있었던 경우(새 세션)
        let isNewSession = checkNewSession()
        
        if isNewSession {
            // 이전에 로깅했던 상태 초기화 (새 세션이므로)
            hasLogged = false
            // 소스는 초기화하지 않음 - 이미 setSource에서 설정된 값 유지
        }
        
        // 아직 로깅하지 않았으면 로깅 수행
        if !hasLogged {
            Analytics.logEvent("app_launch", parameters: ["source": source.rawValue])
            hasLogged = true
            
            print("App launch logged: \(source.rawValue) (New session: \(isNewSession))")
        }
        
        backgroundEntryTime = nil
    }
}
