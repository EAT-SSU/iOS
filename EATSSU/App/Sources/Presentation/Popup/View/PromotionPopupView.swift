//
//  PromotionPopupView.swift
//  EATSSU
//
//  Created by jeongminji on 3/16/26.
//

import UIKit

import SnapKit
import EATSSUDesign

final class PromotionPopupView: BaseUIView {
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    /// 버튼 이외의 공간 클릭할 경우 클릭 인식할 뷰
    let contentTapView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.coffeePromotionPhoto.image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let periodLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.PromotionPopup.period
        label.font = EATSSUDesignFontFamily.Pretendard.semiBold.font(size: 13)
        label.textColor = UIColor(hex: "#1A1A1B")
        label.textAlignment = .right
        return label
    }()
    
    let instagramLinkButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .gray700
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.clipsToBounds = true
        return button
    }()

    private let instagramButtonTitleLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.PromotionPopup.instagramButtonTitle
        label.font = .body2
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()

    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.iconArrowRight.image
        return imageView
    }()

    private let instagramButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()
    
    let guideLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        
        let text = TextLiteral.PromotionPopup.guideMessage
        let font = EATSSUDesignFontFamily.Pretendard.semiBold.font(size: 10)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 24
        paragraphStyle.maximumLineHeight = 24
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor(hex: "#AD5317"),
            .paragraphStyle: paragraphStyle,
            .baselineOffset: (24 - font.lineHeight) / 2
        ]
        
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
        return label
    }()
    
    let neverShowAgainButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(TextLiteral.PromotionPopup.neverShowAgain, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .body2
        button.backgroundColor = .clear
        return button
    }()
    
    let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(TextLiteral.PromotionPopup.close, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .body2
        button.backgroundColor = .clear
        return button
    }()
    
    // MARK: - Life Cycles

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK: - Functions
    
    override func configureUI() {
        backgroundColor = .black.withAlphaComponent(0.6)
        
        [
            containerView,
            neverShowAgainButton,
            closeButton
        ].forEach {
            addSubview($0)
        }
        
        [
            posterImageView,
            periodLabel,
            instagramLinkButton,
            guideLabel,
            contentTapView
        ].forEach {
            containerView.addSubview($0)
        }
        
        instagramLinkButton.addSubview(instagramButtonStackView)
        
        instagramButtonStackView.addArrangedSubview(instagramButtonTitleLabel)
        instagramButtonStackView.addArrangedSubview(arrowImageView)
    }
    
    override func setLayout() {
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(35)
        }
        
        posterImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(30.5)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(posterImageView.snp.width).multipliedBy(281.0 / 272.0)
        }
        
        periodLabel.snp.makeConstraints {
            $0.trailing.equalTo(posterImageView).inset(7.2)
            $0.bottom.equalTo(posterImageView).inset(39.9)
        }
        
        
        instagramLinkButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().inset(47)
            $0.trailing.lessThanOrEqualToSuperview().inset(47)
            $0.bottom.equalTo(posterImageView.snp.bottom).offset(8.5)
        }

        instagramButtonStackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(12)
            $0.verticalEdges.equalToSuperview().inset(8)
        }

        arrowImageView.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
        
        guideLabel.snp.makeConstraints {
            $0.top.equalTo(instagramLinkButton.snp.bottom)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(16)
        }
        
        neverShowAgainButton.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.bottom).offset(11)
            $0.leading.equalToSuperview().inset(35)
            $0.height.equalTo(20)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.bottom).offset(11)
            $0.trailing.equalToSuperview().inset(35)
            $0.height.equalTo(20)
        }
        
        contentTapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
