//
//  RestaurantMenuTitleView.swift
//  EATSSU
//
//  Created by 황상환 on 4/6/25.
//

import UIKit

import SnapKit

import EATSSUDesign

final class RestaurantMenuTitleView: BaseUIView {

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

    private lazy var infoTableStackView: UIStackView = {
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

    override func configureUI() {
        addSubviews(infoTableStackView, lineView)
    }

    override func setLayout() {
        infoTableStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.horizontalEdges.equalToSuperview().inset(12)
        }

        priceLabel.snp.makeConstraints {
            $0.width.equalTo(47)
        }

        ratingLabel.snp.makeConstraints {
            $0.width.equalTo(25)
        }

        lineView.snp.makeConstraints {
            $0.top.equalTo(infoTableStackView.snp.bottom).offset(11)
            $0.horizontalEdges.equalToSuperview().inset(8)
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview().inset(6)
        }
    }
}
