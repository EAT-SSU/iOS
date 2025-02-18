//
//  MenuFeedbackView.swift
//  EATSSU
//
//  Created by 최지우 on 2/13/25.
//

import UIKit

import SnapKit
import EATSSUDesign

enum FeedbackType {
    case like
    case dislike
    case none
}

class MenuFeedbackView: UIView {
    
    // MARK: - Properties
    
    private var selectedFeedback: FeedbackType = .none {
        didSet {
            updateButtonStates()
        }
    }
    
    // MARK: - UI Components
    
    private let menuLabel = UILabel()
    private lazy var likeButton = UIButton()
    private lazy var dislikeButton = UIButton()
    private lazy var buttonStackView = UIStackView()
    private lazy var menuStackView = UIStackView()
    
    // MARK: - Functions
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        setLayout()
        setProperties()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureUI()
        setLayout()
        setProperties()
    }
    
    private func updateButtonStates() {
        switch selectedFeedback {
        case .like:
            likeButton.configuration?.image = EATSSUDesignAsset.Images.filledThumbUp.image
            dislikeButton.configuration?.image = EATSSUDesignAsset.Images.unfilledThumbDown.image
            
            likeButton.configuration?.background.strokeColor = EATSSUDesignAsset.Color.Main.primary.color
            likeButton.configuration?.background.backgroundColor = EATSSUDesignAsset.Color.Main.secondary.color
            
            dislikeButton.configuration?.background.strokeColor = EATSSUDesignAsset.Color.GrayScale.gray300.color
            dislikeButton.configuration?.background.backgroundColor = .white
        case .dislike:
            likeButton.configuration?.image = EATSSUDesignAsset.Images.unfilledThumbUp.image
            dislikeButton.configuration?.image = EATSSUDesignAsset.Images.filledThumbDown.image
            
            dislikeButton.configuration?.background.strokeColor = EATSSUDesignAsset.Color.Main.primary.color
            dislikeButton.configuration?.background.backgroundColor = EATSSUDesignAsset.Color.Main.secondary.color
            
            likeButton.configuration?.background.strokeColor = EATSSUDesignAsset.Color.GrayScale.gray300.color
            likeButton.configuration?.background.backgroundColor = .white
        case .none:
            likeButton.configuration?.background.backgroundColor = .white
            dislikeButton.configuration?.background.backgroundColor = .white
        }
    }
    
    @objc
    func likeButtonTapped() {
        selectedFeedback = .like
    }
    
    @objc
    private func dislikeButtonTapped() {
        selectedFeedback = .dislike
    }
    
    public func configure(with menuName: String) {
        menuLabel.text = menuName
    }
    
}

extension MenuFeedbackView {
    private func configureUI() {
        buttonStackView.addArrangedSubviews([
            likeButton,
            dislikeButton
        ])
        menuStackView.addArrangedSubviews([
            menuLabel,
            buttonStackView
        ])
        addSubviews(
            menuStackView
        )
    }
    
    private func setLayout() {
        menuStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(28)
        }
        [likeButton, dislikeButton].forEach { button in
            button.snp.makeConstraints { make in
                make.width.equalTo(58)
                make.height.equalTo(28)
            }
        }
    }
    
    private func setProperties() {
        menuLabel.do {
            $0.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 14)
        }
        likeButton.do {
            var config = UIButton.Configuration.plain()
            config.image = EATSSUDesignAsset.Images.unfilledThumbUp.image
            config.background.strokeColor = EATSSUDesignAsset.Color.GrayScale.gray300.color
            config.background.strokeWidth = 1
            config.background.cornerRadius = 15
            $0.configuration = config
            $0.addAction(UIAction(handler: { [weak self] _ in
                self?.likeButtonTapped()
            }), for: .touchUpInside)
        }
        dislikeButton.do {
            var config = UIButton.Configuration.plain()
            config.image = EATSSUDesignAsset.Images.unfilledThumbDown.image
            config.background.strokeColor = EATSSUDesignAsset.Color.GrayScale.gray300.color
            config.background.strokeWidth = 1
            config.background.cornerRadius = 15
            $0.configuration = config
            $0.addAction(UIAction(handler: { [weak self] _ in
                self?.dislikeButtonTapped()
            }), for: .touchUpInside)
        }
        buttonStackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.distribution = .fillEqually
            $0.clipsToBounds = false
            $0.isUserInteractionEnabled = true
        }
        menuStackView.do {
            $0.axis = .horizontal
            $0.spacing = 4
            $0.distribution = .fill
        }
    }
}
