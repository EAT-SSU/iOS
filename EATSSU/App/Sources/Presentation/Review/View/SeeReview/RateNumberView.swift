//
//  RateNumberView.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/06/29.
//

import UIKit

import SnapKit

import EATSSUDesign

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

        starImageView.image = EATSSUDesignAsset.Images.icStarYellow.image

        rateNumberLabel.text = "5"
        rateNumberLabel.font = .body2
        rateNumberLabel.textColor = EATSSUDesignAsset.Color.Main.primary.color

        rateNumberStackView.axis = .horizontal
        rateNumberStackView.spacing = 3
        rateNumberStackView.alignment = .center
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
