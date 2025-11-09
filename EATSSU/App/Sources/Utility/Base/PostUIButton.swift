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
            setButtonState(as: isEnabled)
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

    private func setButtonState(as isEnabled: Bool) {
        if isEnabled {
            alpha = 1.0
        } else {
            alpha = 0.5
        }
    }

    func setupButton() {
        layer.cornerRadius = 10
        
        var config = UIButton.Configuration.filled()
        config.contentInsets = NSDirectionalEdgeInsets(top: 9, leading: 0, bottom: 9, trailing: 0)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 14)
            outgoing.foregroundColor = .white
            return outgoing
        }
        config.baseBackgroundColor = EATSSUDesignAsset.Color.Main.primary.color
        config.baseForegroundColor = .white
        configuration = config
        
        contentHorizontalAlignment = .center
        isEnabled = false
    }
}
