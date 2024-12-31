//
//  ESTextField.swift
//  EATSSUComponents
//
//  Created by Jiwoong CHOI on 8/29/24.
//

import Foundation
import UIKit

import SnapKit

/*
 해야 할 일
 - enumeration들을 Namespace라는 폴더로 따로 정리하는 방법은 어떨까?
 */
public enum TextFieldStatus {
    case pass
    case error
}

public final class ESTextField: UITextField {
    // MARK: - Properties

    private enum Size {
        static let height: CGFloat = 52.adjusted
    }

    private var guide: String
    private var status: TextFieldStatus {
        didSet {
            changeTextFieldStatus(status: status)
        }
    }

    // MARK: - Intializer

    public init(placeholder: String) {
        guide = placeholder
        status = .pass

        super.init(frame: .zero)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions

    override public func didMoveToSuperview() {
        setLayout()
    }

    private func configureUI() {
        placeholder = guide
        font = .body2
        textColor = .gray700
        backgroundColor = .gray100
        setRoundBorder()
        setPlaceholderColor()
        addLeftPadding(width: 12.adjusted)
    }

    private func setLayout() {
        snp.makeConstraints {
            $0.height.equalTo(Size.height)
        }
    }

    private func changeTextFieldStatus(status: TextFieldStatus) {
        switch status {
        case .pass:
            layer.borderColor = EATSSUDesignAsset.Colors.GrayScaleColor.gray300.color.cgColor
        case .error:
            layer.borderColor = EATSSUDesignAsset.Colors.RedColor.error.color.cgColor
        }
    }
}
