//
//  BaseViewControllerProtocol.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 1/28/25.
//

import UIKit

/// EATSSU 앱에서 UIViewController의 공통 인터페이스를 정의하는 프로토콜입니다.
protocol BaseViewControllerProtocol: AnyObject {
    // MARK: - Required Methods

    /// UIViewController에서 사용 중인 UIView를 연결합니다.
    ///
    /// # Example
    /// ```swift
    /// func configureUI() {
    ///     view.addSubview(rootView)
    /// }
    /// ```
    func configureUI()

    /// 연결된 UIView 클래스의 레이아웃을 UIViewController의 View 프로퍼티를 기준으로 레이아웃을 조정합니다.
    ///
    /// # Example
    /// ```swift
    /// func setLayout() {
    ///     rootView.snp.makeConstraints { make in
    ///         make.edges.equalToSuperview()
    ///     }
    /// }
    /// ```
    func setLayout()

    // MARK: - Optional Methods

    /// UIViewController에서 버튼이 있다면 버튼 액션을 연결합니다.
    ///
    /// 버튼이 없다면 기본적으로 비워둡니다.
    func setButtonEvent()

    /// EATSSU 앱에서 사용하고 있는 네비게이션 바의 속성을 정의합니다.
    func setESNavigationBar()
}

// MARK: - Default Implementation

extension BaseViewControllerProtocol {
    func setButtonEvent() {}
    func setESNavigationBar() {}
}
