//
//  ESAlertUtility.swift
//  EATSSUKit
//
//  Created by JIWOONG CHOI on 1/31/25.
//

import UIKit

/// - Note: 앱 전반에서 재사용할 수 있는 알림창(팝업) 유틸리티 클래스입니다.
public enum ESAlertUtility {
    // MARK: - Common Alert

    /// - Note: 일반적인 알림 창을 생성하는 함수입니다.
    public static func showAlert(
        title: String?,
        message: String?,
        confirmTitle: String = "확인",
        in viewController: UIViewController
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: confirmTitle, style: .default, handler: nil)
        alert.addAction(confirmAction)
        viewController.present(alert, animated: true, completion: nil)
    }

    // MARK: - Confirm Alert

    /// - Note: 사용자의 확인이 필요한 알림 창을 생성하는 함수입니다.
    public static func showConfirmAlert(
        title: String?,
        message: String?,
        confirmTitle: String = "확인",
        cancelTitle: String = "취소",
        in viewController: UIViewController,
        confirmHandler: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: confirmTitle, style: .default) { _ in
            confirmHandler?()
        }
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)

        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        viewController.present(alert, animated: true, completion: nil)
    }

    /// - Note: 취소 버튼 없이 확인 버튼만 있는 알림 창을 생성하는 함수입니다.
    public static func showConfirmOnlyAlert(
        title: String?,
        message: String?,
        confirmTitle: String = "확인",
        in viewController: UIViewController,
        confirmHandler: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: confirmTitle, style: .default) { _ in
            confirmHandler?()
        }

        alert.addAction(confirmAction)
        viewController.present(alert, animated: true, completion: nil)
    }

    // MARK: - Action Sheet

    /// - Note: 사용자에게 여러 선택지를 제공하는 액션 시트를 생성하는 함수입니다.
    public static func showActionSheet(
        title: String?,
        message: String?,
        actions: [(String, UIAlertAction.Style, (() -> Void)?)],
        in viewController: UIViewController
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)

        for (title, style, handler) in actions {
            let action = UIAlertAction(title: title, style: style) { _ in
                handler?()
            }
            alert.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        viewController.present(alert, animated: true, completion: nil)
    }
}
