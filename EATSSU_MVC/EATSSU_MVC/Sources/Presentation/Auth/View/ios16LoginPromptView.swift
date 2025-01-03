//
//  ios16LoginPromptView.swift
//  EATSSU
//
//  Created by 최지우 on 11/28/24.
//

import UIKit

final class ios16LoginPromptView: BaseUIView {
    
    // MARK: - UI Components
    
    private let loginAlertLabel = UILabel()
    private let appleLoginButton = UIButton()
    private let kakaoLoginButton = UIButton()
    private let buttonStackView = UIStackView()
    private let loginPromptStackView = UIStackView()
    private let buttonView = UIView()
    
    // MARK: - Intializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setViewProperties()
    }
    
    // MARK: - Functions
    
    private func setViewProperties() {
        loginAlertLabel.do {
            $0.text = TextLiteral.SignIn.loginPrompt
            $0.textAlignment = .left
            $0.numberOfLines = 0
            $0.font = EATSSUFontFamily.Pretendard.bold.font(size: 18)
            $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
        }
        
        appleLoginButton.do {
            $0.setImage(EATSSUAsset.Images.Version2.appleLoginButton.image, for: .normal)
        }
        
        kakaoLoginButton.do {
            $0.setImage(EATSSUAsset.Images.Version2.kakaoLoginButton.image, for: .normal)
        }
        
        buttonStackView.do {
            $0.axis = .vertical
            $0.spacing = 8
        }
        
        loginPromptStackView.do {
            $0.axis = .vertical
        }
    }
    
    override func configureUI() {
        addSubview(loginPromptStackView)
        buttonView.addSubview(buttonStackView)
        
        buttonStackView.addArrangedSubviews([appleLoginButton,
                                             kakaoLoginButton])
        loginPromptStackView.addArrangedSubviews([loginAlertLabel,
                                                  buttonView])
    }
    
    override func setLayout() {
        loginAlertLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints{
            $0.center.equalToSuperview()
        }
        
        loginPromptStackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.height.equalToSuperview().multipliedBy(0.7)
            $0.bottom.equalToSuperview().multipliedBy(0.85)
        }
    }
}

