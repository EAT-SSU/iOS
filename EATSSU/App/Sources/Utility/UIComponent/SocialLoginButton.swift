//
//  SocialLoginButton.swift
//  EATSSU
//
//  Created by jeongminji on 5/4/26.
//

import UIKit

import SnapKit

import EATSSUDesign

// MARK: - extension UIColor: 카카오 로그인 버튼 규격

private extension UIColor {
    static let kakaoContainer = UIColor(
        red: 254 / 255,
        green: 229 / 255,
        blue: 0 / 255,
        alpha: 1.0
    )

    static let kakaoSymbol = UIColor.black

    static let kakaoLabel = UIColor.black.withAlphaComponent(0.85)
}

final class SocialLoginButton: UIButton {
    
    // MARK: - Properties
    
    enum LoginType {
        case apple
        case kakao
        
        var title: String {
            switch self {
            case .apple:
                return TextLiteral.Auth.signInWithApple
            case .kakao:
                return TextLiteral.Auth.signInWithKakao
            }
        }
        
        var backgroundColor: UIColor {
            switch self {
            case .apple:
                return .black
            case .kakao:
                return .kakaoContainer
            }
        }
        
        var titleColor: UIColor {
            switch self {
            case .apple:
                return .white
            case .kakao:
                return .kakaoLabel
            }
        }
        
        var icon: UIImage {
            switch self {
            case .apple:
                return EATSSUDesignAsset.Images.appleLoginLogo.image
            case .kakao:
                return EATSSUDesignAsset.Images.kakaoLoginLogo.image
            }
        }
        
        var iconVerticalInset: CGFloat {
            switch self {
            case .apple:
                return 11
            case .kakao:
                return 14
            }
        }
        
        var iconAspectRatio: CGFloat {
            return icon.size.width / icon.size.height
        }
    }
    
    private enum Constant {
        static let buttonAspectRatio = 45.0 / 300.0
    }
    
    private let type: LoginType
    
    // MARK: - UI Components
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let loginTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Initializer
    
    init(type: LoginType) {
        self.type = type
        super.init(frame: .zero)
        
        configureUI()
        setLayout()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func configureUI() {
        layer.cornerRadius = 5
        clipsToBounds = true
        
        addSubviews(iconImageView, loginTitleLabel)
    }
    
    private func setLayout() {
        snp.makeConstraints {
            $0.height.equalTo(snp.width).multipliedBy(Constant.buttonAspectRatio)
        }
        
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(15)
            $0.verticalEdges.equalToSuperview().inset(type.iconVerticalInset)
            $0.width.equalTo(iconImageView.snp.height).multipliedBy(type.iconAspectRatio)
        }
        
        loginTitleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func configure() {
        backgroundColor = type.backgroundColor
        iconImageView.image = type.icon
        loginTitleLabel.text = type.title
        loginTitleLabel.textColor = type.titleColor
    }
}
