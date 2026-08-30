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
    
    private let logoSubTitle: UILabel = {
        let label = UILabel()
        label.font = .header2
        label.attributedText = TextLiteral.Auth.loginSubTitle.highlighted(
            TextLiteral.Auth.loginSubTitleHighlight,
            baseColor: .black,
            highlightColor: .primary
        )
        return label
    }()
    
    let appleLoginButton = SocialLoginButton(type: .apple)
    
    let kakaoLoginButton = SocialLoginButton(type: .kakao)
    
    let lookingWithNoSignInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(TextLiteral.Auth.lookingWithNoSignIn, for: .normal)
        button.setTitleColor(.gray400, for: .normal)
        button.titleLabel?.font = .body2
        button.backgroundColor = .clear
        return button
    }()

    let goodPriceEntryButton = GoodPriceEntryButton()

    /// 서울동아리ON / SEOUL MY SOUL 로고 (서울시 지원사업 필수 표기)
    private let sponsorLogoStackView: UIStackView = {
        let clubOnLogo = UIImageView(image: EATSSUDesignAsset.Images.seoulClubOnLogo.image)
        clubOnLogo.contentMode = .scaleAspectFit
        clubOnLogo.snp.makeConstraints {
            $0.height.equalTo(18)
            $0.width.equalTo(clubOnLogo.snp.height).multipliedBy(LoginView.aspectRatio(of: clubOnLogo.image))
        }

        let divider = UIView()
        divider.backgroundColor = .gray300
        divider.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.height.equalTo(20)
        }

        let mySoulLogo = UIImageView(image: EATSSUDesignAsset.Images.seoulMySoulLogo.image)
        mySoulLogo.contentMode = .scaleAspectFit
        mySoulLogo.snp.makeConstraints {
            $0.height.equalTo(16)
            $0.width.equalTo(mySoulLogo.snp.height).multipliedBy(LoginView.aspectRatio(of: mySoulLogo.image))
        }

        let stack = UIStackView(arrangedSubviews: [clubOnLogo, divider, mySoulLogo])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 20
        return stack
    }()
    
    private var lastLoginTooltipView: LastLoginTooltipView?

    /// 이미지 가로/세로 비율 (없으면 1)
    private static func aspectRatio(of image: UIImage?) -> CGFloat {
        guard let size = image?.size, size.height > 0 else { return 1 }
        return size.width / size.height
    }

    override func configureUI() {
        addSubviews(
            logoImage,
            logoSubTitle,
            appleLoginButton,
            kakaoLoginButton,
            lookingWithNoSignInButton,
            goodPriceEntryButton,
            sponsorLogoStackView
        )
    }

    override func setLayout() {
        logoImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(appleLoginButton.snp.top).offset(-120)
        }

        logoSubTitle.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(logoImage.snp.bottom)
        }

        appleLoginButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(45)
            $0.bottom.equalTo(kakaoLoginButton.snp.top).offset(-16)
        }

        kakaoLoginButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(45)
            $0.bottom.equalTo(lookingWithNoSignInButton.snp.top).offset(-16)
        }

        lookingWithNoSignInButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(goodPriceEntryButton.snp.top).offset(-28)
        }

        goodPriceEntryButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(45)
            $0.bottom.equalTo(sponsorLogoStackView.snp.top).offset(-40)
        }

        sponsorLogoStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(24)
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
