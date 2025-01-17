//
//  PostUIButton.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/04.
//

import UIKit

import SnapKit

class PostUIButton: UIButton {
    override var isEnabled: Bool {
        didSet {
            isEnabled ? setEnableButton() : setDisableButton()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setEnableButton() {
        isUserInteractionEnabled = true
        backgroundColor = EATSSUAsset.Color.Main.primary.color
    }

    private func setDisableButton() {
        isUserInteractionEnabled = false
        backgroundColor = EATSSUAsset.Color.Main.secondary.color
    }

    func setupButton() {
        backgroundColor = EATSSUAsset.Color.Main.secondary.color
        setTitleColor(.white, for: .normal)
        titleLabel?.font = EATSSUFontFamily.Pretendard.bold.font(size: 14)
        layer.cornerRadius = 10
        /*
         해야 할 일
         - UIEdgeInsets은 iOS 15.0에서 deprecated 되었기에, 수정 필요
         */
        contentEdgeInsets = UIEdgeInsets(top: 9, left: 0, bottom: 9, right: 0)
        contentHorizontalAlignment = .center
        isEnabled = false
    }
}
