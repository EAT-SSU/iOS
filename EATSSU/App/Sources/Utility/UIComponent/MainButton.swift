//
//  MainButton.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/04/03.
//

import UIKit

import EATSSUDesign

import SnapKit
import Then

class MainButton: UIButton {
    private enum Size {
        static let height: CGFloat = 48.adjusted
    }

    // MARK: - Property

    var title: String? {
        didSet {
            setupTitleAttribute()
        }
    }

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Function

    func configureUI() {
        titleLabel?.font = .button1
        titleLabel?.textColor = .white
        backgroundColor = EATSSUDesignAsset.Color.Main.primary.color
        layer.cornerRadius = 10
    }

    func setLayout() {
        snp.makeConstraints {
            $0.height.equalTo(Size.height)
        }
    }

    func setupTitleAttribute() {
        if let buttonTitle = title {
            setTitle(buttonTitle, for: .normal)
        }
    }
}
