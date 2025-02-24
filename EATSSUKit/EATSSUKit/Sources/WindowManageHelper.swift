//
//  WindowManageHelper.swift
//  EATSSUKit
//
//  Created by JIWOONG CHOI on 2/24/25.
//

import Foundation
import UIKit

/// `WindowManageHelper`는 앱의 윈도우에 대한 관리 작업을 지원하는 헬퍼 클래스입니다.
///
/// 이 헬퍼는 현재 앱의 활성 윈도우에서 루트 뷰 컨트롤러를 교체할 때 사용됩니다.
public enum WindowManageHelper {
    
    /// 현재 활성 윈도우의 루트 뷰 컨트롤러를 주어진 뷰 컨트롤러로 교체합니다.
    ///
    /// - Parameter viewController: 새로운 루트로 설정할 `UIViewController` 인스턴스입니다.
    /// 해당 뷰 컨트롤러는 `UINavigationController`로 래핑되어 설정됩니다.
    ///
    /// 이 메서드는 다음 단계를 수행합니다:
    /// 1. 활성화된 `UIWindowScene`을 검색합니다.
    /// 2. 키 윈도우(`keyWindow`)를 찾습니다.
    /// 3. 해당 윈도우의 루트 뷰 컨트롤러를 새로운 뷰 컨트롤러로 교체합니다.
    ///
    /// - Note:
    /// 이 메서드는 주로 전체 화면 전환이나 로그인/로그아웃 후 초기 화면으로 복귀하는 등의 시나리오에서 유용하게 사용됩니다.
    ///
    /// - Example:
    /// ```swift
    /// let loginViewController = LoginViewController()
    /// WindowManageHelper.replaceWindowViewControllerWith(loginViewController)
    /// ```
    public static func replaceWindowViewControllerWith(_ viewController: UIViewController) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
        {
            keyWindow.replaceRootViewController(UINavigationController(rootViewController: viewController))
        }
    }
}
