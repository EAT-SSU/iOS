//
//  GoodPriceEntryButton.swift
//  EATSSU
//
//  Created by 황상환 on 8/23/26.
//

import UIKit

import SnapKit

import EATSSUDesign

/// 로그인 화면의 "착한가격업소 둘러보기" 카드형 버튼
final class GoodPriceEntryButton: UIControl {

    // MARK: - UI Components

    private let iconBackgroundView = UIView()
    /// 에셋이 템플릿이 아니라서 tintColor(흰색)가 먹도록 렌더링 모드를 지정
    private let iconImageView = UIImageView(
        image: EATSSUDesignAsset.Images.restaurantPin.image.withRenderingMode(.alwaysTemplate)
    )
    private let titleLabel = UILabel()
    private let subTitleLabel = UILabel()
    private let textStackView = UIStackView()
    private let chevronImageView = UIImageView(
        image: UIImage(
            systemName: "chevron.right",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        )
    )

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Highlight

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.6 : 1 }
    }

    // MARK: - Setup

    private func configureUI() {
        backgroundColor = UIColor.primary.withAlphaComponent(0.08)
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.primary.cgColor

        iconBackgroundView.backgroundColor = .primary
        iconBackgroundView.layer.cornerRadius = 18
        iconBackgroundView.isUserInteractionEnabled = false

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white

        titleLabel.text = TextLiteral.Auth.goodPriceEntryTitle
        titleLabel.font = .subtitle1
        titleLabel.textColor = .label

        subTitleLabel.text = TextLiteral.Auth.goodPriceEntrySubTitle
        subTitleLabel.font = .caption2
        subTitleLabel.textColor = .gray700

        textStackView.axis = .vertical
        textStackView.spacing = 2
        textStackView.isUserInteractionEnabled = false
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(subTitleLabel)

        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.tintColor = .primary

        iconBackgroundView.addSubview(iconImageView)
        addSubviews(iconBackgroundView, textStackView, chevronImageView)
    }

    private func setLayout() {
        snp.makeConstraints { $0.height.equalTo(68) }

        iconBackgroundView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(36)
        }

        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        textStackView.snp.makeConstraints {
            $0.leading.equalTo(iconBackgroundView.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(chevronImageView.snp.leading).offset(-8)
        }

        chevronImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }
    }
}
