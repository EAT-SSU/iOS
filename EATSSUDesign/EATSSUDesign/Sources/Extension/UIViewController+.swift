//
//  UIViewController+.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/02/13.
//

import SwiftUI
import UIKit.UIViewController

#if DEBUG
    extension UIViewController {
        private struct Preview: UIViewControllerRepresentable {
            let viewController: UIViewController

            func makeUIViewController(context _: Context) -> UIViewController {
                viewController
            }

            func updateUIViewController(_: UIViewController, context _: Context) {}
        }

        func toPreview() -> some View {
            Preview(viewController: self)
        }
    }
#endif

extension UIViewController {
    public func dismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(UIViewController.dismissKeyboardTouchOutside))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboardTouchOutside() {
        view.endEditing(true)
    }

    /// UIAlertController를 생성하는 모듈 메소드입니다.
    ///
    ///  - Parameters:
    ///   - title: AlertController 제목
    ///   - message: AlertController 메시지
    ///   - style: AlertAction 스타일
    ///   - action: 컨트롤러 액션
    public func showAlertController(title: String, message: String, style: UIAlertAction.Style, action: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "확인", style: style) { _ in
            action?()
        }
        alert.addAction(confirmAction)

        present(alert, animated: true)
    }

    /// 취소항목이 있는 UIAlertController를 생성하는 모듈 메소드입니다.
    ///
    /// - Parameters:
    ///   - title: AlertController 제목
    ///   - message: AlertController 메시지
    ///   - confirmStyle: AlertController 확인 스타일
    ///   - cancelStyle: AlertController 취소 스타일
    ///   - action: 컨트롤러 액션
    public func showAlertControllerWithCancel(title: String,
                                       message: String,
                                       confirmStyle: UIAlertAction.Style,
                                       cancelStyle: UIAlertAction.Style = .cancel,
                                       action: (() -> Void)? = nil)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let confirmButton = UIAlertAction(title: "네", style: confirmStyle) { _ in
            action?()
        }
        let cancelButton = UIAlertAction(title: "아니오", style: cancelStyle) { _ in
        }

        alert.addAction(confirmButton)
        alert.addAction(cancelButton)

        present(alert, animated: true)
    }
}
