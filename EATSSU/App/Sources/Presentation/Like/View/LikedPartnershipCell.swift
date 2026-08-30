//
//  LikedPartnershipCell.swift
//  EATSSU
//
//  Created by 황상환 on 8/30/26.
//

import UIKit

import SnapKit

import EATSSUDesign

/// 찜한 제휴 업체 한 줄: [체크(편집 모드)] 업종 아이콘 · 업체명 · 업종 · 제휴 내용 · 화살표
final class LikedPartnershipCell: UITableViewCell {

    // MARK: - Types

    enum Mode {
        case normal
        case editing(isSelected: Bool)
    }

    // MARK: - Constants

    static let identifier = "LikedPartnershipCell"

    /// 디자인(390pt 기준): 좌우 24, 아이콘 36, 텍스트 간격 12, 행 높이 77, 화살표 8×12 trailing 28
    private enum Layout {
        static let horizontalInset: CGFloat = 24
        static let iconSize: CGFloat = 36
        static let checkSize: CGFloat = 18
        static let checkLeading: CGFloat = 27
        static let textSpacing: CGFloat = 12
        static let checkTextSpacing: CGFloat = 15
        static let topInset: CGFloat = 18
        static let bottomInset: CGFloat = 16
        static let chevronTrailing: CGFloat = 28
    }

    // MARK: - UI Components

    private let checkImageView = UIImageView()
    private let iconImageView = UIImageView()
    private let nameLabel = UILabel()
    private let typeLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
    private let titleStackView = UIStackView()
    private let textStackView = UIStackView()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
        setLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Setup

    private func configureUI() {
        selectionStyle = .none
        backgroundColor = .white

        checkImageView.contentMode = .scaleAspectFit
        checkImageView.isHidden = true

        iconImageView.contentMode = .scaleAspectFit

        nameLabel.font = .subtitle1
        nameLabel.textColor = .label
        nameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        typeLabel.font = .caption2
        typeLabel.textColor = .gray600
        typeLabel.setContentHuggingPriority(.required, for: .horizontal)
        typeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        descriptionLabel.font = .body3
        descriptionLabel.textColor = .gray600
        descriptionLabel.numberOfLines = 1
        descriptionLabel.lineBreakMode = .byTruncatingTail

        chevronImageView.tintColor = .gray300
        chevronImageView.contentMode = .scaleAspectFit

        titleStackView.axis = .horizontal
        titleStackView.alignment = .lastBaseline
        titleStackView.spacing = 8
        titleStackView.addArrangedSubview(nameLabel)
        titleStackView.addArrangedSubview(typeLabel)

        textStackView.axis = .vertical
        textStackView.alignment = .leading
        textStackView.spacing = 8
        textStackView.addArrangedSubview(titleStackView)
        textStackView.addArrangedSubview(descriptionLabel)

        contentView.addSubviews(checkImageView, iconImageView, textStackView, chevronImageView)
    }

    private func setLayout() {
        checkImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Layout.checkLeading)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(Layout.checkSize)
        }

        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Layout.horizontalInset)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(Layout.iconSize)
        }

        chevronImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(Layout.chevronTrailing)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(8)
            $0.height.equalTo(12)
        }

        textStackView.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(Layout.textSpacing)
            $0.trailing.lessThanOrEqualTo(chevronImageView.snp.leading).offset(-16)
            $0.top.equalToSuperview().inset(Layout.topInset)
            $0.bottom.equalToSuperview().inset(Layout.bottomInset)
        }
    }

    // MARK: - Configuration

    func configure(store: PartnershipDTO, mode: Mode) {
        nameLabel.text = store.storeName
        typeLabel.text = PartnershipFilter.allCases
            .first { $0.restaurantType == store.restaurantType }?
            .title ?? store.restaurantType
        descriptionLabel.text = store.partnershipInfos.map(\.description).joined(separator: ", ")
        iconImageView.image = MainMapViewController.partnershipIcon(for: store.restaurantType, isFestival: false)

        let leadingAnchor: ConstraintItem
        let spacing: CGFloat
        switch mode {
        case .normal:
            checkImageView.isHidden = true
            iconImageView.isHidden = false
            leadingAnchor = iconImageView.snp.trailing
            spacing = Layout.textSpacing
        case .editing(let isSelected):
            // 편집 모드에서는 업종 아이콘 대신 체크박스를 보여준다
            checkImageView.isHidden = false
            iconImageView.isHidden = true
            checkImageView.image = isSelected
                ? EATSSUDesignAsset.Images.icCheck.image
                : EATSSUDesignAsset.Images.icUncheck.image
            leadingAnchor = checkImageView.snp.trailing
            spacing = Layout.checkTextSpacing
        }
        textStackView.snp.remakeConstraints {
            $0.leading.equalTo(leadingAnchor).offset(spacing)
            $0.trailing.lessThanOrEqualTo(chevronImageView.snp.leading).offset(-16)
            $0.top.equalToSuperview().inset(Layout.topInset)
            $0.bottom.equalToSuperview().inset(Layout.bottomInset)
        }
    }
}
