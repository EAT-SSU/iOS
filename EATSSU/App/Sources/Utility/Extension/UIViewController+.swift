//
//  UIViewController+.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/02/13.
//

import UIKit.UIViewController

import EATSSUDesign
import SwiftUI // Keep SwiftUI import in case other parts of the app uses it for things unrelated to the removed toPreview function

extension UIViewController {
    func logScreenView(screenID: String) {
        AnalyticsService.logScreen(screenID, screenClass: String(describing: type(of: self)))
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
        cancelAction: (() -> Void)? = nil,
        confirmAction: @escaping () -> Void
    ) {
        tabBarContainer?.showDialog(
            title: title,
            message: message,
            cancelButtonTitle: cancelButtonTitle,
            confirmButtonTitle: confirmButtonTitle,
            cancelAction: cancelAction,
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
