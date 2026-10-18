//
//  PushRoute.swift
//  EATSSU
//
//  Created by 황상환 on 10/17/26.
//

import UIKit

/// 학식 알림을 눌렀을 때 이동할 학식 화면 (날짜 + 시간대)
struct PushRoute {
    /// 학식 탭 시간대 순서 (아침·점심·저녁)
    enum MealTime: String {
        case morning = "MORNING"
        case lunch = "LUNCH"
        case dinner = "DINNER"

        var tabIndex: Int {
            switch self {
            case .morning: 0
            case .lunch: 1
            case .dinner: 2
            }
        }
    }

    let date: Date
    /// 찜 알림에만 있다. 없으면(일반 학식 알림) 현재 시각 기준 시간대를 그대로 쓴다
    let mealTime: MealTime?

    /// 서버 푸시 data: `type`(MENU_FAVORITE / DAILY_MENU), `date`(yyyyMMdd), `timePart`(찜 알림만)
    init?(userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["type"] as? String,
              Self.supportedTypes.contains(type),
              let dateString = userInfo["date"] as? String,
              let date = Self.dateFormatter.date(from: dateString) else { return nil }
        self.date = date
        self.mealTime = (userInfo["timePart"] as? String).flatMap(MealTime.init(rawValue:))
    }

    private static let supportedTypes: Set<String> = ["MENU_FAVORITE", "DAILY_MENU"]

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()
}

/// 알림을 누른 시점에 화면이 준비돼 있지 않을 수 있어(앱 실행 직후 스플래시·로그인 등) 이동할 곳을 보관했다가 적용한다
final class PushRouter {

    static let shared = PushRouter()

    private init() {}

    private var pendingRoute: (route: PushRoute, receivedAt: Date)?

    /// 보관한 이동의 유효 시간. 로그인 화면에서 알림을 누른 뒤 한참 지나 로그인하면 예전 날짜로 튀지 않게 한다
    private static let pendingRouteLifetime: TimeInterval = 5 * 60

    /// 알림 응답을 받으면 호출. 앱이 이미 활성 상태면 바로, 아니면 `sceneDidBecomeActive`에서 적용한다
    func handle(userInfo: [AnyHashable: Any]) {
        guard let route = PushRoute(userInfo: userInfo) else { return }
        pendingRoute = (route, Date())
        if UIApplication.shared.applicationState == .active {
            applyPendingRoute()
        }
    }

    /// 보관된 이동을 적용. 탭바가 아직 없으면(스플래시·로그인 중) 그대로 두고, 탭바가 나타날 때 다시 시도한다
    ///
    /// 다음 런루프에서 실행해, 같은 시점에 예약된 "새로운 날 → 오늘로 초기화"(`didEnterNewDay`) 처리보다 뒤에 적용되게 한다
    func applyPendingRoute() {
        DispatchQueue.main.async { [weak self] in
            guard let self, let pending = self.pendingRoute else { return }
            guard Date().timeIntervalSince(pending.receivedAt) < Self.pendingRouteLifetime else {
                self.pendingRoute = nil
                return
            }
            guard let tabBarController = Self.currentTabBarController() else { return }
            self.pendingRoute = nil
            tabBarController.showHomeMenu(on: pending.route.date, mealTime: pending.route.mealTime)
        }
    }

    private static func currentTabBarController() -> CustomTabBarContainerController? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first { $0.isKeyWindow }
        return window?.rootViewController as? CustomTabBarContainerController
    }
}
