//
//  LoginPromptViewController.swift
//  EATSSU
//
//  Created by 최지우 on 11/26/24.
//

import UIKit

final class LoginPromptViewController: BaseViewController {
    
    // MARK: - UI Components
    
    private let loginAlertLabel = UILabel()
    private let appleLoginButton = UIButton()
    private let kakaoLoginButton = UIButton()
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewProperties()
    }
    
    // MARK: - Functions
    
    private func setViewProperties() {
        loginAlertLabel.do {
            $0.text = TextLiteral.SignIn.loginPrompt
            $0.textAlignment = .left
            $0.numberOfLines = 0
            $0.font = EATSSUFontFamily.Pretendard.bold.font(size: 18)
        }
        
        appleLoginButton.do {
            $0.setImage(EATSSUAsset.Images.Version2.appleLoginButton.image, for: .normal)
        }
        
        kakaoLoginButton.do {
            $0.setImage(EATSSUAsset.Images.Version2.kakaoLoginButton.image, for: .normal)
        }
    }
    
    override func configureUI() {
        view.addSubviews(
            loginAlertLabel,
            appleLoginButton,
            kakaoLoginButton
        )
    }
    
    override func setLayout() {
        loginAlertLabel.snp.makeConstraints {
            $0.top.leading.equalTo(view.safeAreaLayoutGuide).offset(30.adjusted)
        }
        
        appleLoginButton.snp.makeConstraints {
            // $0.top.equalTo(loginAlertLabel.snp.bottom).offset(44.adjusted)
            $0.bottom.equalTo(kakaoLoginButton.snp.top).offset(8)
            $0.centerX.equalToSuperview()
            
        }
        
        kakaoLoginButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
            $0.centerX.equalToSuperview()
        }
    }
}
