//
//  BaseUIView.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/03/15.
//

// TODO: BaseUIView 코드 Utility 모듈로 모듈화 간 재정비

import UIKit

/// EATSSU 앱에서 스크린으로 사용될 UIView 클래스의 BaseView 클래스입니다.
///
/// # 소속 메소드
/// - configureUI
/// - setLayout
///
/// - Important: configureUI()와 setLayout() 메소드를 오버라이딩 해야 합니다.
/// 오버라이딩 하지 않으면 런타임 에러가 발생합니다.
class BaseUIView: UIView {
	override init(frame: CGRect) {
		super.init(frame: frame)

		configureUI()
		setLayout()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	/// 서브뷰를 추가하는 코드를 오버라이딩하여 작성해주세요.
	///
	///	# Example
	///
	/// ```swift
	///	override func configureUI() {
	///		addSubviews(view1, view2)
	///	}
	/// ```
	///
	/// - 위의 형식과 같이 서브뷰로 사용할 UIView 클래스를 추가해주시면 됩니다.
	func configureUI() {
		// FIXME: 컴파일 타임에서 오버라이딩 의무화 여부를 확인하는 방법으로 재설계
	}

	/// 추가한 서브뷰의 레이아웃을 조정하는 코드를 오버라이딩하여 작성해주세요.
	///
	/// # Example
	///
	/// ```swift
	///	override func setLayout() {
	///		view1.snp.makeConstraints { make in
	///			make.center.equalToSuperview()
	///		}
	///	}
	/// ```
	///
	/// - 위의 형식과 같이 추가한 서브뷰의 레이아웃을 조정하는 메소드를 작성해주세요.
	func setLayout() {
		// FIXME: 컴파일 타임에서 오버라이딩 의무화 여부를 확인하는 방법으로 재설계
	}
}
