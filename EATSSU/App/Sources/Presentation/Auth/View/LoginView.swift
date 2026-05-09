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

    private var lastLoginTooltipView: LastLoginTooltipView?

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
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(176)
        }

        kakaoLoginButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(115)
        }

        lookingWithNoSignInButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(30)
        }
    }

    // MARK: - Tooltip

    /// 마지막 로그인 제공자에 따라 말풍선 툴팁을 표시한다.
    func showLastLoginTooltip(provider: UserInfo.AccountType) {
        lastLoginTooltipView?.removeFromSuperview()

        let tooltipSpacing: CGFloat = 4

        switch provider {
        case .apple:
            let tooltip = LastLoginTooltipView(arrowDirection: .down)
            addSubview(tooltip)
            tooltip.snp.makeConstraints {
                $0.centerX.equalTo(appleLoginButton)
                $0.bottom.equalTo(appleLoginButton.snp.top).offset(-tooltipSpacing)
            }
            lastLoginTooltipView = tooltip

        case .kakao:
            let tooltip = LastLoginTooltipView(arrowDirection: .up)
            addSubview(tooltip)
            tooltip.snp.makeConstraints {
                $0.centerX.equalTo(kakaoLoginButton)
                $0.top.equalTo(kakaoLoginButton.snp.bottom).offset(tooltipSpacing)
            }
            lastLoginTooltipView = tooltip
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissTooltip))
        lastLoginTooltipView?.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissTooltip() {
        UIView.animate(withDuration: 0.2, animations: {
            self.lastLoginTooltipView?.alpha = 0
        }, completion: { _ in
            self.lastLoginTooltipView?.removeFromSuperview()
            self.lastLoginTooltipView = nil
        })
    }
}
