//
//  RateNumberView.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/06/29.
//

import UIKit

import EATSSUDesign
import SnapKit

final class StarRatingView: BaseUIView {
    
    // MARK: - UI Components

    private let starImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.icStarYellow.image
        return imageView
    }()
    
    private lazy var rateNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "5"
        label.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 40)
        return label
    }()
    
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
    
    // MARK: - Functions

    override func configureUI() {
        addSubviews(rateNumberStackView)

        rateNumberLabel.do {
            $0.text = "5"
            $0.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 40)
        }

        rateNumberStackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
        }
    }

    override func setLayout() {
        starImageView.snp.makeConstraints {
            $0.height.equalTo(24.adjusted)
            $0.width.equalTo(24.adjusted)
        }

        rateNumberStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    public func updateStarRating(_ rate: Double) {
        rateNumberLabel.text = String(format: "%.1f", rate)
    }
}
