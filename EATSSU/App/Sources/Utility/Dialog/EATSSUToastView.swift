//
//  EATSSUToastView.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 10/16/25.
//

import UIKit

import SnapKit

import EATSSUDesign

enum ToastType {
    case danger
    case info
    case success
    case warning
    
    var backgroundColor: UIColor {
        switch self {
        case .danger:
            return .dangerBg
        case .info:
            return .infoBg
        case .success:
            return .successBg
        case .warning:
            return .warningBg
        }
    }
    
    var borderColor: UIColor {
        switch self {
        case .danger:
            return .dangerBr
        case .info:
            return .infoBr
        case .success:
            return .successBr
        case .warning:
            return .warningBr
        }
    }
    
    var mainColor: UIColor {
        switch self {
        case .danger:
            return .danger
        case .info:
            return .info
        case .success:
            return .success
        case .warning:
            return .warning
        }
    }
    
    var iconImage: UIImage? {
        switch self {
        case .danger:
            return EATSSUDesignAsset.Images.iconDanger.image
        case .info:
            return EATSSUDesignAsset.Images.iconInfo.image
        case .success:
            return EATSSUDesignAsset.Images.iconSuccess.image
        case .warning:
            return EATSSUDesignAsset.Images.warning.image
        }
    }
}

class EATSSUToastView: BaseUIView {
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.masksToBounds = true
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .body2
        label.textColor = .gray700
        label.numberOfLines = 0
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton()
        button.setTitle("보러가기", for: .normal)
        button.titleLabel?.font = .button2
        button.isHidden = true
        return button
    }()
    
    // MARK: - Properties
    
    private var toastType: ToastType = .info
    var actionHandler: (() -> Void)?
    
    // MARK: - Override Methods
    
    override func configureUI() {
        backgroundColor = .clear
        
        addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(messageLabel)
        containerView.addSubview(actionButton)
        
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    override func setLayout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(48)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(8)
            make.top.bottom.equalToSuperview().inset(14)
            make.trailing.lessThanOrEqualTo(actionButton.snp.leading).offset(-12)
        }
        
        actionButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Public Methods
    
    func configure(type: ToastType, message: String, showAction: Bool = false) {
        self.toastType = type
        
        containerView.backgroundColor = type.backgroundColor
        containerView.layer.borderColor = type.borderColor.cgColor
        iconImageView.image = type.iconImage
        messageLabel.text = message
        actionButton.setTitleColor(type.mainColor, for: .normal)
        
        actionButton.isHidden = !showAction
        
        if !showAction {
            messageLabel.snp.remakeConstraints { make in
                make.leading.equalTo(iconImageView.snp.trailing).offset(8)
                make.top.bottom.equalToSuperview().inset(14)
                make.trailing.equalToSuperview().inset(16)
            }
        } else {
            messageLabel.snp.remakeConstraints { make in
                make.leading.equalTo(iconImageView.snp.trailing).offset(8)
                make.top.bottom.equalToSuperview().inset(14)
                make.trailing.lessThanOrEqualTo(actionButton.snp.leading).offset(-12)
            }
        }
    }
    
    func setActionButtonTitle(_ title: String) {
        actionButton.setTitle(title, for: .normal)
    }
    
    // MARK: - Private Methods
    
    @objc private func actionButtonTapped() {
        actionHandler?()
    }
    
    // MARK: - Animation Methods

    func show(in view: UIView, duration: TimeInterval = 2.0) {
        view.addSubview(self)
        
        let superviewHeight = view.bounds.height
        
        let bottomOffset = superviewHeight * 0.03
        
        self.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-bottomOffset)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        if duration > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.hide()
            }
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
