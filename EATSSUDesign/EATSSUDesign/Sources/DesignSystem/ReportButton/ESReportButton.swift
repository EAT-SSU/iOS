//
//  ESReportButton.swift
//  EATSSUComponents
//
//  Created by Jiwoong CHOI on 8/29/24.
//

// Swift Module
import Foundation
import UIKit

// External Module
import SnapKit

public final class ESReportButton: UIButton {
    // MARK: - Properties

    override public var isSelected: Bool {
        didSet {
            updateButtonAppearance()
        }
    }

    // MARK: - Intializer

    /// Swift 이니셜라이저 다형성, 지정 이니셜라이저, 편의 이니셜라이저 사용성에 관한 메모
    /// - 지정 연산자를 오버라이딩 하는지 여부에 따라서 설계할 수 있는 이니셜라이저가 다르다.

    /// 지정 이니셜라이저 (Designated Intializer)를 오버라이딩 하는 경우 아래의 코드와 같은 형식으로 설계한다.
    /// self.init를 사용했다는 것이 중요하다.
    /// 해당 클래스 안에 지정 연산자를 오버라이딩 했기 때문에 super.init이 아니라 self.init을 사용해야 한다.

    /*
     public convenience init(title: String) {
     self.init(frame: .zero)
     self.setProperties(title: title)
     }

     override public init(frame: CGRect) {
     super.init(frame: frame)
     }
     */

    /// 지정 이니셜라이저 (Designated Intializer)를 오버라이딩 하지 않으면, 단순 호출만 하면 되는 것이기 때문에,
    /// 아래와 같이 코드를 설계한다.
    /// super.init을 사용했다는 것이 중요하다.
    /// 지정 이니셜라이저를 오버라이딩 하지 않았기 떄문에, 이니셜라이저를 직접 설계하고 super.init 지정 이니셜라이저를 호출하면 된다.

    /// 회색 컬러의 ReportButton
    ///
    /// - Parameter title: 버튼 타이틀
    public init(title: String) {
        super.init(frame: .zero)
        setProperties(title: title)
        setupButton()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    private func setProperties(title: String) {
        backgroundColor = .white

        layer.borderWidth = 1
        layer.borderColor = EATSSUDesignAsset.Colors.GrayScaleColor.gray300.color.cgColor
        layer.cornerRadius = 10

        setTitle(title, for: .normal)
        setTitleColor(.black, for: .normal)
        titleLabel?.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 14)
        contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        // TODO: Deprecated. UIButtonConfiguration 속성 사용할 경우 해당사항 적용안됨 / Configuration 속성으로 수정 필요
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
    }

    private func setupButton() {
        updateButtonAppearance()

        addTarget(self, action: #selector(esReportButtonTapped), for: .touchUpInside)
    }

    @objc
    private func esReportButtonTapped() {
        isSelected.toggle()
        updateButtonAppearance()
    }

    private func updateButtonAppearance() {
        if isSelected {
            backgroundColor = EATSSUDesignAsset.Colors.MainColor.secondary.color
            layer.borderColor = EATSSUDesignAsset.Colors.MainColor.primary.color.cgColor
        } else {
            backgroundColor = .white
            layer.borderColor = EATSSUDesignAsset.Colors.GrayScaleColor.gray300.color.cgColor
        }
    }
}
