//
//  ReviewSummaryView.swift
//  EATSSU
//
//  Created by 최지우 on 2/18/25.
//

import UIKit

import SnapKit
import EATSSUDesign

final class ReviewSummaryView: BaseUIView {
    
    // MARK: - UI Components
    
    private var menuLabel: UILabel = {
        let label = UILabel()
        label.text = "고구마치즈돈까스+막국수+미니밥+단무지+요구르트고구마치즈돈까스+막국수+미니밥+단무지+요구르트고구마치즈돈까스+막국수+미니밥+단무지"
        label.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 18)
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: 좌측
    
    private var starRatingView = StarRatingView()
    private let thumbupCountView = ThumbsCountView(thumbType: .up)
    private let thumbdownpCountView = ThumbsCountView(thumbType: .down)
    
    private lazy var thumbCountStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [thumbupCountView, thumbdownpCountView])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 14
        stackView.backgroundColor = .purple
        return stackView
    }()
    
    private lazy var ratingSummaryStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [starRatingView, thumbCountStackView])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.backgroundColor = .gray300
        return stackView
    }()
    
    // MARK: 우측
    
    private let totalReviewTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "총 리뷰 수"
        label.font = .caption2
        label.textColor = .black
        return label
    }()

    private let totalReviewCountLabel: UILabel = {
        let label = UILabel()
        label.text = "15"
        label.font = .caption1
        label.textColor = EATSSUDesignAsset.Color.Main.primary.color
        label.backgroundColor = .purple
        return label
    }()
        
    private lazy var totalReviewStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [totalReviewTitleLabel, totalReviewCountLabel])
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.backgroundColor = .blue
        return stackView
    }()
    
    private let oneChartComponentView = ChartComponentView()
    private let twoChartComponentView = ChartComponentView()
    private let threeChartComponentView = ChartComponentView()
    private let fourChartComponentView = ChartComponentView()
    private let fiveChartComponentView = ChartComponentView()
    
    private lazy var yAxisStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [oneChartComponentView,
                                                       twoChartComponentView,
                                                       threeChartComponentView,
                                                       fourChartComponentView,
                                                       fiveChartComponentView])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.backgroundColor = .yellow
        return stackView
    }()
    
    private lazy var reviewDistributionStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [totalReviewStackView, yAxisStackView])
        stackView.axis = .vertical
        stackView.spacing = 5
        return stackView
    }()
    
    // MARK: - 좌측 + 우측

    private lazy var ratingAndDistributionStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [ratingSummaryStackView,
                                                       reviewDistributionStackView])
        stackView.axis = .horizontal
//        stackView.spacing = 44
        stackView.backgroundColor = .brown
        return stackView
    }()
    
    // MARK: - total

    private lazy var reviewSummaryStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [menuLabel, ratingAndDistributionStackView])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.backgroundColor = .orange
        return stackView
    }()
    
    // MARK: - Functions
    
    override func configureUI() {
        addSubviews(reviewSummaryStackView)
    }
    
    override func setLayout() {
        reviewSummaryStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(20.adjusted)
            make.bottom.equalToSuperview()
        }
    }
}

extension ReviewSummaryView {
    
}
