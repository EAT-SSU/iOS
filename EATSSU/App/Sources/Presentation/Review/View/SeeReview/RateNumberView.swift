//
//  RateNumberView.swift
//  EATSSU
//
//  Created by 최지우 on 2/19/25.
//

import UIKit

import EATSSUDesign

import SnapKit
import Then

// TODO: - 추후 제거(StarRatingView으로 리팩됨)

final class RateNumberView: BaseUIView {
    // MARK: - UI Components

    let starImageView = UIImageView()
    lazy var rateNumberLabel = UILabel()
    private lazy var rateNumberStackView = UIStackView(arrangedSubviews: [starImageView,
                                                                          rateNumberLabel])

    // MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    // MARK: - Functions

    override func configureUI() {
        addSubviews(rateNumberStackView)
        starImageView.do {
            $0.image = EATSSUDesignAsset.Images.icStarYellow.image
        }

        rateNumberLabel.do {
            $0.text = "5"
            $0.font = .body2
            $0.textColor = EATSSUDesignAsset.Color.Main.primary.color
        }

        rateNumberStackView.do {
            $0.axis = .horizontal
            $0.spacing = 3
            $0.alignment = .top
        }
    }

    override func setLayout() {
        starImageView.snp.makeConstraints {
            $0.height.equalTo(12.adjusted)
            $0.width.equalTo(12.adjusted)
        }

        rateNumberStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
