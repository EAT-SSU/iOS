//
//  DepartmentInfoRequestModalViewController.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 2/18/25.
//

import UIKit

/// 학과 정보가 입력되지 않은 경우, 모달 시트를 띄워 학과 정보 입력 화면으로 유도하는 뷰 컨트롤러.
final class DepartmentInfoRequestModalViewController: BaseViewController {
    public var onButtonTapped: (() -> Void)?

    override public func loadView() {
        view = DepartmentInfoModalView()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setButtonEvent() {
        if let modalView = view as? DepartmentInfoModalView {
            modalView.actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
    }

    @objc private func buttonTapped() {
        #if DEBUG
            print("DepartmentInfoModalView 버튼이 클릭되었습니다.")
        #endif
        onButtonTapped?()
    }
}
