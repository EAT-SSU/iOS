//
//  EATSSUDialogView.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 10/16/25.
//

import UIKit

import SnapKit

import EATSSUDesign

class EATSSUDialogView: BaseUIView {
    
    // MARK: - UI Components
    
    private let dimmedView = UIView()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 28
        view.layer.masksToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "제목을 입력해주세요"
        label.font = .header2
        label.textColor = .gray700
        label.textAlignment = .center
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "본문을 입력해주세요"
        label.font = .subtitle2
        label.textColor = .gray600
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.gray700, for: .normal)
        button.titleLabel?.font = .subtitle2
        button.backgroundColor = .gray200
        button.layer.cornerRadius = 12
        return button
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .subtitle2
        button.backgroundColor = .primary
        button.layer.cornerRadius = 12
        return button
    }()
    
    // MARK: - Properties
    
    var isSingleButton: Bool = false {
        didSet {
            updateButtonLayout()
        }
    }
    
    // MARK: - Override Methods
    
    override func configureUI() {
        backgroundColor = .clear
        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        addSubview(dimmedView)
        addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(buttonStackView)
        
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(confirmButton)
    }
    
    override func setLayout() {
        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(321)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(28)
            make.leading.trailing.equalToSuperview().inset(18)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(18)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().inset(18)
            make.height.equalTo(48)
        }
    }
    
    // MARK: - Public Methods
    
    func configure(title: String, message: String, isSingleButton: Bool = false) {
        titleLabel.text = title
        messageLabel.text = message
        self.isSingleButton = isSingleButton
    }
    
    func setButtonTitles(cancel: String? = nil, confirm: String) {
        if !isSingleButton {
            cancelButton.setTitle(cancel ?? "취소", for: .normal)
        }
        confirmButton.setTitle(confirm, for: .normal)
    }
    
    func getDimmedView() -> UIView {
        return dimmedView
    }
    
    func getContainerView() -> UIView {
        return containerView
    }
    
    // MARK: - Private Methods
    
    private func updateButtonLayout() {
        if isSingleButton {
            cancelButton.removeFromSuperview()
            buttonStackView.snp.remakeConstraints { make in
                make.top.equalTo(messageLabel.snp.bottom).offset(18)
                make.leading.trailing.equalToSuperview().inset(18)
                make.bottom.equalToSuperview().inset(18)
                make.height.equalTo(48)
            }
        } else {
            if cancelButton.superview == nil {
                buttonStackView.insertArrangedSubview(cancelButton, at: 0)
            }
        }
    }
}
