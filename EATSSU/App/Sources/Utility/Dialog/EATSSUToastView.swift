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
            return EATSSUDesignAsset.Color.dangerBg.color
        case .info:
            return EATSSUDesignAsset.Color.infoBg.color
        case .success:
            return EATSSUDesignAsset.Color.successBg.color
        case .warning:
            return EATSSUDesignAsset.Color.warningBg.color
        }
    }
    
    var borderColor: UIColor {
        switch self {
        case .danger:
            return EATSSUDesignAsset.Color.dangerBr.color
        case .info:
            return EATSSUDesignAsset.Color.infoBr.color
        case .success:
            return EATSSUDesignAsset.Color.successBr.color
        case .warning:
            return EATSSUDesignAsset.Color.warningBr.color
        }
    }
    
    var MianColor: UIColor {
        switch self {
        case .danger:
            return EATSSUDesignAsset.Color.danger.color
        case .info:
            return EATSSUDesignAsset.Color.info.color
        case .success:
            return EATSSUDesignAsset.Color.success.color
        case .warning:
            return EATSSUDesignAsset.Color.warning.color
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
        label.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 14)
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray700.color
        label.numberOfLines = 0
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton()
        button.setTitle("보러가기", for: .normal)
        button.setTitleColor(EATSSUDesignAsset.Color.Main.primary.color, for: .normal)
        button.titleLabel?.font = EATSSUDesignFontFamily.Pretendard.semiBold.font(size: 14)
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
        
        // Add shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        
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
    
    func show(in view: UIView, duration: TimeInterval = 3.0) {
        view.addSubview(self)
        
        self.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(-60)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        view.layoutIfNeeded()
        
        self.snp.updateConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            view.layoutIfNeeded()
        } completion: { _ in
            if duration > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    self.hide()
                }
            }
        }
    }
    
    func hide() {
        guard let superview = self.superview else { return }
        
        self.snp.updateConstraints { make in
            make.top.equalTo(superview.safeAreaLayoutGuide).offset(-60)
        }
        
        UIView.animate(withDuration: 0.3) {
            superview.layoutIfNeeded()
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}
