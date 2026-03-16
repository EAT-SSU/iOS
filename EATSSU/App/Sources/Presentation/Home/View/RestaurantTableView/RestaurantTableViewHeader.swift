//
//  RestaurantTableViewHeader.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/08/09.
//

import UIKit

import SnapKit

import EATSSUDesign

class RestaurantTableViewHeader: BaseTableViewHeaderView {
    static let identifier = "RestaurantTableViewHeader"

    let titleLabel = UILabel()
    let infoButton = UIButton()
    let stackView = UIStackView()

    var infoButtonDidTappedCallback: (() -> Void)?

    // MARK: - Functions

    override func configure() {
        super.configure()

        configureUI()
        setLayout()
        setViewProperties()
    }

    func setViewProperties() {
        titleLabel.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 16)
        titleLabel.text = TextLiteral.Home.dormitoryRestaurant

        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = .gray600
        configuration.image = EATSSUDesignAsset.Images.icInfo.image
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 4.0
        infoButton.configuration = configuration

        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
    }

    func configureUI() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubviews([titleLabel,
                                       infoButton])
    }

    func setLayout() {
        stackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(22)
            $0.centerY.equalToSuperview()
        }
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
        }
        infoButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
        }
    }
}
