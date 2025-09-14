//
//  RestaurantTableViewMenuTitleCell.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/08/09.
//

import UIKit

import SnapKit

import EATSSUDesign

class RestaurantTableViewMenuTitleCell: BaseTableViewCell {
    // MARK: - Properties

    static let identifier = "RestaurantTableViewMenuTitleCell"

    // MARK: - UI Components

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.Home.todayMenu
        label.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 14)
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.Home.price
        label.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 14)
        label.textAlignment = .center
        return label
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.Home.rating
        label.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 14)
        label.textAlignment = .center
        return label
    }()

    lazy var infoTableStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameLabel, priceLabel, ratingLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 24
        return stackView
    }()

    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray200
        return view
    }()

    // MARK: - Functions

    override func configureUI() {
        super.configureUI()
        contentView.addSubviews(infoTableStackView, lineView)
    }

    override func setLayout() {
        infoTableStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.horizontalEdges.equalToSuperview().inset(12)
        }

        nameLabel.snp.makeConstraints {
            $0.width.equalTo(210).priority(.high)
        }

        priceLabel.snp.makeConstraints {
            $0.width.equalTo(47).priority(.high)
        }

        ratingLabel.snp.makeConstraints {
            $0.width.equalTo(25).priority(.high)
        }

        lineView.snp.makeConstraints {
            $0.top.equalTo(infoTableStackView.snp.bottom).offset(11)
            $0.horizontalEdges.equalToSuperview().inset(8)
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview()
        }
    }
}
