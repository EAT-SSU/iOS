//
//  ios15LoginPromptView.swift
//  EATSSU
//
//  Created by 최지우 on 11/28/24.
//

import UIKit

final class ios15LoginPromptView: BaseUIView {
    
    // MARK: - UI Components
    
    private let loginAlertLabel = UILabel()
    private let appleLoginButton = UIButton()
    private let kakaoLoginButton = UIButton()
    private let logoImage = UIImageView()
    private let logoSubTitleImage = UIImageView()
    private let logoStackView = UIStackView()
    private let buttonStackView = UIStackView()
    private let loginPromptStackView = UIStackView()
    
    
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
        
        logoImage.do {
            $0.image = EATSSUAsset.Images.Version2.authLogo.image
        }
        
        logoSubTitleImage.do {
            $0.image = EATSSUAsset.Images.Version2.authSubTitle.image
        }
        
        buttonStackView.do {
            $0.spacing = 8
        }
        
        logoStackView.do {
            $0.alignment = .center
        }
        
        loginPromptStackView.do {
            $0.distribution = .equalSpacing
        }
        
        [buttonStackView,logoStackView,loginPromptStackView].forEach {
            $0.axis = .vertical
        }
    }
    
    override func configureUI() {
        addSubview(loginPromptStackView)
        
        logoStackView.addArrangedSubviews([logoImage,
                                           logoSubTitleImage])
        buttonStackView.addArrangedSubviews([appleLoginButton,
                                             kakaoLoginButton])
        loginPromptStackView.addArrangedSubviews([loginAlertLabel,
                                                  logoStackView,
                                                  buttonStackView])
        
//        loginPromptStackView.backgroundColor = .yellow
//        logoStackView.backgroundColor = .gray
//        buttonStackView.backgroundColor = .green
//        logoImage.backgroundColor = .blue
//        logoSubTitleImage.backgroundColor = .red

    }
    
    override func setLayout() {
        loginAlertLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
        }
        
        logoImage.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(100)
            $0.height.equalTo(46)
        }
        
        logoSubTitleImage.snp.makeConstraints {
            $0.width.equalTo(70)
            $0.height.equalTo(10)
        }

        loginPromptStackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.height.equalToSuperview().multipliedBy(0.75)
            $0.bottom.equalToSuperview().multipliedBy(0.85)
        }
    }
}

