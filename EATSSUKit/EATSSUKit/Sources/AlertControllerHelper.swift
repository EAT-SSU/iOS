//
//  AlertControllerHelper.swift
//  EATSSUKit
//
//  Created by JIWOONG CHOI on 1/31/25.
//

import UIKit

/// 앱 전반에서 재사용할 수 있는 알림창(팝업) 유틸리티 클래스입니다.
public enum AlertControllerHelper {
    /**
     사용자의 확인이 필요한 알림 창을 생성하는 함수입니다.

     - Parameters:
       - title: 알림 창의 제목입니다. `nil`일 경우 제목이 표시되지 않습니다.
       - message: 알림 창에 표시할 메시지입니다. `nil`일 경우 메시지가 표시되지 않습니다.
       - confirmTitle: 확인 버튼에 표시할 텍스트입니다. 기본값은 "확인"입니다.
       - cancelTitle: 취소 버튼에 표시할 텍스트입니다. 기본값은 "취소"입니다.
       - viewController: 알림 창을 표시할 뷰 컨트롤러입니다.
       - confirmHandler: 확인 버튼 선택 시 실행할 클로저입니다. 선택 사항으로, 전달하지 않을 경우 아무 동작도 하지 않습니다.

     - Note: 확인 버튼을 누르면 `confirmHandler`가 실행되며, 취소 버튼은 별도의 동작 없이 알림 창을 닫습니다.
     */
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

    /**
     취소 버튼 없이 확인 버튼만 있는 알림 창을 생성하는 함수입니다.

     - Parameters:
       - title: 알림 창의 제목입니다. `nil`일 경우 제목이 표시되지 않습니다.
       - message: 알림 창에 표시할 메시지입니다. `nil`일 경우 메시지가 표시되지 않습니다.
       - confirmTitle: 확인 버튼에 표시할 텍스트입니다. 기본값은 "확인"입니다.
       - viewController: 알림 창을 표시할 뷰 컨트롤러입니다.
       - confirmHandler: 확인 버튼 선택 시 실행할 클로저입니다. 선택 사항으로, 전달하지 않을 경우 아무 동작도 하지 않습니다.

     - Note: 확인 버튼을 누르면 `confirmHandler`가 실행됩니다.
     */
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
}
