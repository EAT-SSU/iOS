//
//  LoginPromptViewController.swift
//  EATSSU
//
//  Created by 최지우 on 11/26/24.
//

import UIKit

final class LoginPromptViewController: BaseViewController {
    
    // MARK: - UI Components
    
    private let loginAlertLabel: UILabel = {
        let label = UILabel()
        label.text = "3초만에 로그인하고\n리뷰를 달아보세요!"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = EATSSUFontFamily.Pretendard.bold.font(size: 18)
        return label
    }()
    
    private let appleLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(EATSSUAsset.Images.Version2.appleLoginButton.image, for: .normal)
        return button
    }()
    
    private let kakaoLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(EATSSUAsset.Images.Version2.kakaoLoginButton.image, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.backgroundColor = .yellow
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
//            $0.top.equalTo(loginAlertLabel.snp.bottom).offset(44.adjusted)
            $0.bottom.equalTo(kakaoLoginButton.snp.top).offset(8)
            $0.centerX.equalToSuperview()
            
        }
        kakaoLoginButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
            $0.centerX.equalToSuperview()
        }
    }
}
