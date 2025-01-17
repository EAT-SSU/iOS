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
                return viewController
            }

            func updateUIViewController(_: UIViewController, context _: Context) {}
        }

        func toPreview() -> some View {
            Preview(viewController: self)
        }
    }
#endif

extension UIViewController {
    func dismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(UIViewController.dismissKeyboardTouchOutside))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboardTouchOutside() {
        view.endEditing(true)
    }

    func presentBottomAlert(_ message: String) {
        let alertSuperview: UIView = {
            let view = UIView()
            view.backgroundColor = .darkGray.withAlphaComponent(0.85)
            view.layer.cornerRadius = 10
            view.isHidden = true
            return view
        }()

        let alertLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 15)
            label.textColor = .white
            label.text = message
            return label
        }()

        view.addSubview(alertSuperview)
        alertSuperview.addSubview(alertLabel)
        alertSuperview.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(35)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(40)
        }

        alertLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        alertLabel.text = message
        alertSuperview.alpha = 1.0
        alertSuperview.isHidden = false

        UIView.animate(
            withDuration: 2.0,
            delay: 1.0,
            options: .curveEaseIn,
            animations: { alertSuperview.alpha = 0 },
            completion: { _ in
                alertSuperview.removeFromSuperview()
            }
        )
    }

    /// UIAlertController를 생성하는 모듈 메소드입니다.
    ///
    ///  - Parameters:
    ///   - title: AlertController 제목
    ///   - message: AlertController 메시지
    ///   - style: AlertAction 스타일
    ///   - action: 컨트롤러 액션
    func showAlertController(title: String, message: String, style: UIAlertAction.Style, action: (() -> Void)? = nil) {
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
    func showAlertControllerWithCancel(title: String,
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
