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

//    let starImageView = UIImageView()
    private var starImageViews: [UIImageView] = []
    private lazy var starsStackView = UIStackView()
//    lazy var rateNumberLabel = UILabel()
//    private lazy var rateNumberStackView = UIStackView(arrangedSubviews: [starImageView,
    private lazy var rateNumberStackView = UIStackView(arrangedSubviews: [starsStackView,
                                                                          /*rateNumberLabel*/])

    var filledStarImage: UIImage? = EATSSUDesignAsset.Images.icStarYellow.image
    var emptyStarImage: UIImage? = EATSSUDesignAsset.Images.icStarGray.image

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

//        starImageView.image = EATSSUDesignAsset.Images.icStarYellow.image
        starImageViews = (0..<5).map { _ in
            let imageView = UIImageView()
//            imageView.image = EATSSUDesignAsset.Images.icStarYellow.image.withRenderingMode(.alwaysTemplate)
//            imageView.tintColor = EATSSUDesignAsset.Color.gray3.color
            imageView.image = emptyStarImage
            return imageView
        }
        
        starsStackView.axis = .horizontal
        starsStackView.spacing = 3
        starsStackView.alignment = .bottom
        starImageViews.forEach { starsStackView.addArrangedSubview($0) }


//        rateNumberLabel.text = "5"
//        rateNumberLabel.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 14)
//        rateNumberLabel.textColor = EATSSUDesignAsset.Color.Main.primary.color

        rateNumberStackView.axis = .horizontal
//        rateNumberStackView.spacing = 3
        rateNumberStackView.spacing = 6
        rateNumberStackView.alignment = .bottom
    }

    override func setLayout() {
//        starImageView.snp.makeConstraints {
//            $0.height.equalTo(12.adjusted)
//            $0.width.equalTo(12.adjusted)
        starImageViews.forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(12.adjusted)
                $0.width.equalTo(12.adjusted)
            }
        }

        rateNumberStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    
    func setRating(_ rating: Int) {
        for (index, star) in starImageViews.enumerated() {
            if index < rating {
                star.image = filledStarImage
            } else {
                star.image = emptyStarImage
            }
        }
//        rateNumberLabel.text = "\(rating)"
    }
}
