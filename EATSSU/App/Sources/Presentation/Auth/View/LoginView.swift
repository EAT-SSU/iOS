//
//  LoginView.swift
//  iOS
//
//  Created by 최지우 on 2023/06/26.
//

import UIKit

import SnapKit

import EATSSUDesign

final class LoginView: BaseUIView {
    // MARK: - UI Components

    private let logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.authLogo.image
        return imageView
    }()

    private let logoSubTitle: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.authSubTitle.image
        return imageView
    }()

    let appleLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(EATSSUDesignAsset.Images.appleLoginButton.image, for: .normal)
        return button
    }()

    let kakaoLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(EATSSUDesignAsset.Images.kakaoLoginButton.image, for: .normal)
        return button
    }()

    let lookingWithNoSignInButton: UIButton = {
        let button = UIButton()
        button.setImage(EATSSUDesignAsset.Images.lookAroundButton.image, for: .normal)
        return button
    }()

    override func configureUI() {
        addSubviews(
            logoImage,
            logoSubTitle,
            appleLoginButton,
            kakaoLoginButton,
            lookingWithNoSignInButton
        )
    }

    override func setLayout() {
        logoImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(223)
        }

        logoSubTitle.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(logoImage.snp.bottom)
        }

        appleLoginButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(151)
        }

        kakaoLoginButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(90)
        }

        lookingWithNoSignInButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(30)
        }
    }
}
