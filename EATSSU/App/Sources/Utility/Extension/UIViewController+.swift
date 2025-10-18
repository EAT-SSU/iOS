//
//  UIViewController+.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/02/13.
//

import SwiftUI
import UIKit.UIViewController

import FirebaseAnalytics

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
    func dismissKeyboard() {
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
    
    func logScreenView(screenID: String) {
        Analytics.logEvent(AnalyticsEventScreenView,
                           parameters: [AnalyticsParameterScreenName: screenID,
                                       AnalyticsParameterScreenClass: String(describing: type(of: self))])
    }
    
    // MARK: - Custom Dialog
    
    /// 앱의 최상위 뷰 컨트롤러인 CustomTabBarContainerController를 찾아 반환합니다.
    var tabBarContainer: CustomTabBarContainerController? {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let controller = windowScene.windows.first?.rootViewController as? CustomTabBarContainerController {
            return controller
        }
        return nil
    }
    
    /// 공용 다이얼로그를 표시합니다. (EATSSUDialogView 사용)
    func showCustomDialog(
        title: String,
        message: String,
        cancelButtonTitle: String = "취소하기",
        confirmButtonTitle: String = "확인",
        confirmAction: @escaping () -> Void
    ) {
        // tabBarContainer를 통해 최상위 뷰에 다이얼로그를 띄우도록 요청합니다.
        tabBarContainer?.showDialog(
            title: title,
            message: message,
            cancelButtonTitle: cancelButtonTitle,
            confirmButtonTitle: confirmButtonTitle,
            confirmAction: confirmAction
        )
    }
    
    // MARK: - Custom Toast
    
    /// 공용 토스트 메시지를 표시합니다. (EATSSUToastView 사용)
    ///
    /// - Parameters:
    ///   - message: 토스트에 표시될 메시지
    ///   - type: 토스트의 종류 (.success, .danger, .info, .warning)
    ///   - duration: 토스트가 화면에 표시될 시간 (초)
    ///   - actionTitle: (선택) 액션 버튼에 표시될 텍스트
    ///   - actionHandler: (선택) 액션 버튼을 눌렀을 때 실행될 클로저
    func showToast(
        message: String,
        type: ToastType = .info,
        duration: TimeInterval = 2.0,
        actionTitle: String? = nil,
        actionHandler: (() -> Void)? = nil
    ) {
        let toastView = EATSSUToastView()
        
        // 액션 버튼 표시 여부 결정
        let showAction = (actionTitle != nil)
        
        // 토스트 뷰 설정
        toastView.configure(type: type, message: message, showAction: showAction)
        
        // 액션 버튼이 필요한 경우, 타이틀과 핸들러 설정
        if let title = actionTitle {
            toastView.setActionButtonTitle(title)
            toastView.actionHandler = actionHandler
        }
        
        // 현재 뷰 컨트롤러의 view에 토스트를 띄움
        toastView.show(in: self.view, duration: duration)
    }
}
