//
//  StarSummaryView.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/06/29.
//

import UIKit

import EATSSUDesign
import SnapKit

final class StarSummaryView: BaseUIView {
    
    // MARK: - UI Components

    private let starImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.icStarYellow.image
        return imageView
    }()
    
    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.text = "5.0"
        label.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 35)
        return label
    }()
    
    private lazy var starRatingStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [starImageView, ratingLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
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
        addSubviews(starRatingStackView)
    }

    override func setLayout() {
        starImageView.snp.makeConstraints {
            $0.height.equalTo(25.adjusted)
            $0.width.equalTo(25.adjusted)
        }

        starRatingStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    public func updateStarRating(_ rate: Double) {
        ratingLabel.text = String(format: "%.1f", rate)
    }
}
