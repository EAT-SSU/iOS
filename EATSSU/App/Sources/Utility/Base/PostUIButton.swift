//
//  PostUIButton.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/04.
//

import UIKit

import SnapKit

import EATSSUDesign

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
        backgroundColor = EATSSUDesignAsset.Color.Main.primary.color
    }

    private func setDisableButton() {
        isUserInteractionEnabled = false
        backgroundColor = EATSSUDesignAsset.Color.Main.secondary.color
    }

    func setupButton() {
        backgroundColor = EATSSUDesignAsset.Color.Main.secondary.color
        setTitleColor(.white, for: .normal)
        titleLabel?.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 14)
        layer.cornerRadius = 10
        
        var config = UIButton.Configuration.filled()
        config.contentInsets = NSDirectionalEdgeInsets(top: 9, leading: 0, bottom: 9, trailing: 0)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 14)
            return outgoing
        }
        config.baseBackgroundColor = EATSSUDesignAsset.Color.Main.secondary.color
        configuration = config
        
        contentHorizontalAlignment = .center
        isEnabled = false
    }
}
