//
//  DepartmentInfoModalViewController.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 2/18/25.
//

import UIKit

/// 학과 정보가 입력되지 않은 경우, 모달 시트를 띄워 학과 정보 입력 화면으로 유도하는 뷰 컨트롤러.
public class DepartmentInfoModalViewController: UIViewController {
    /// 버튼 탭 시 호출할 클로저 (필요 시 사용)
    public var onButtonTapped: (() -> Void)?

    // 커스텀 뷰를 루트 뷰로 설정
    override public func loadView() {
        view = DepartmentInfoModalView()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        // DepartmentInfoModalView에 액션 연결
        if let modalView = view as? DepartmentInfoModalView {
            modalView.actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
    }

    /// 버튼 탭 시 모달 종료 후 디버그 콘솔에 로그 출력
    @objc private func buttonTapped() {
        dismiss(animated: true) {
            #if DEBUG
                print("DepartmentInfoModalView 버튼이 클릭되었습니다.")
            #endif
        }
    }
}
