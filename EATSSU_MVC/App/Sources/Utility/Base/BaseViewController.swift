//
//  BaseViewController.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/03/15.
//

// TODO: BaseViewController 코드 Utility 모듈로 모듈화 간 재정비

import UIKit

import Moya
import SnapKit

/// EATSSU 앱에서 Controller로 사용하는 BaseViewController 클래스입니다.
///
/// # 소속 메소드
/// - configureUI
/// - setLayout
/// - setButtonEvent
/// - setCustomnavigationBar
///
/// - Important: configureUI와 setLayout 메소드는 필수로 오버라이딩 해야 합니다.
/// 오버라이딩 하지 않으면 런타임 에러가 발생합니다.
class BaseViewController: UIViewController {
    // MARK: - Properties

    private(set) lazy var className: String = type(of: self).description().components(separatedBy: ".").last ?? ""

    // MARK: - Initialize

    override init(nibName _: String?, bundle _: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // TODO: deinit 메소드의 목적이 무엇인지 알아보기
    deinit {
        print("DEINIT: \(className)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        setLayout()
        setButtonEvent()
        setCustomNavigationBar()
        view.backgroundColor = .systemBackground
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !NetworkMonitor.shared.isConnected {
            print("네트워크 오류")
            showAlertController(title: "오류", message: "네트워크를 확인해주세요", style: .destructive)
        }
    }

    // MARK: - Functions

    /// UIViewController에서 사용 중인 UIView를 연결합니다.
    ///
    /// 메소드를 오버라이딩해서 View로 사용할 UIView 클래스를 연결하세요.
    ///
    /// # Example
    ///
    /// ```swift
    ///	override func configureUI() {
    ///		view.addSubview(rootView)
    ///	}
    /// ```
    func configureUI() {
        // FIXME: 컴파일 타임에서 오버라이딩 의무화 여부를 확인하는 방법으로 재설계
    }

    /// 연결된 UIView 클래스의 레이아웃을 UIViewController의 View 프로퍼티를 기준으로 레이아웃을 조정합니다.
    ///
    /// 메소드를 오버라이딩해서 연결된 UIView 클래스의 레이아웃을 조정하세요.
    ///
    /// # Example
    ///
    ///	```swift
    ///	override func setLayout() {
    ///		rootView.snp.makeConstraints { make in
    ///			make.edges.equalToSuperView()
    ///		}
    ///	}
    ///	```
    func setLayout() {
        // FIXME: 컴파일 타임에서 오버라이딩 의무화 여부를 확인하는 방법으로 재설계
    }

    // TODO: setButtonEvent를 setButtonAction으로 변경했으면 합니다.

    /// UIViewController에서 버튼이 있다면 버튼 액션을 연결해주세요.
    ///
    /// 버튼이 있다면 오버라이딩해서 버튼 액션을 연결해주세요.
    /// 없는 UIViewController도 있기 때문에 오버라이딩을 강조하지 않습니다.
    func setButtonEvent() {}

    /// EATSSU 앱에서 사용하고 있는 네비게이션 바의 속성을 정의합니다.
    ///
    /// # 네비게이션 타이틀 속성
    ///	- `gray700`으로 타이틀 색상을 설정합니다.
    ///	- `Pretendard Bold 16`으로 폰트를 설정합니다.
    ///
    /// # 네비게이션 백버튼 속성
    /// - `gray500`으로 백버튼 색상을 설정합니다.
    func setCustomNavigationBar() {
        // 네비게이션 바 타이틀 속성
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: EATSSUAsset.Color.GrayScale.gray700.color,
            NSAttributedString.Key.font: EATSSUFontFamily.Pretendard.bold.font(size: 16),
        ]

        // 네비게이션 바 백버튼 속성
        let backButton = UIBarButtonItem()
        backButton.tintColor = EATSSUAsset.Color.GrayScale.gray500.color
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
}
