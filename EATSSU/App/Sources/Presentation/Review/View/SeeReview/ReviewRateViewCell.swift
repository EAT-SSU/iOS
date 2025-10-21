//
//  ReviewRateViewCell.swift
//  EatSSU-iOS
//
//  Created by 황상환 on 2025/10/21.
//

import UIKit

import SnapKit

import EATSSUDesign

final class ReviewRateViewCell: UITableViewCell {
    // MARK: - Properties
    
    static let identifier = "ReviewRateViewCell"
    var handler: (() -> Void)?
    var totalRate: Double = 0
    
    // MARK: - UI Components
    
    // 메뉴 섹션
    private let menuLabel: UILabel = {
        let label = UILabel()
        label.font = .header2
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    // 왼쪽 평점 섹션 컨테이너
    private let leftRatingContainer = UIView()
    
    private let mainRatingView = MainRatingView()
    private let detailRatingView = DetailRatingView()
    
    // 오른쪽 차트 섹션 컨테이너
    private let rightChartContainer = UIView()
    
    private let reviewCountView = ReviewCountView()
    private let chartView = RatingChartView()
    
    // 리뷰 작성 버튼
    private let addReviewButton: UIButton = {
        let button = UIButton()
        button.setTitle("리뷰 작성하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .bold(size: 14)
        button.backgroundColor = EATSSUDesignAsset.Color.Main.primary.color
        button.layer.cornerRadius = 10
        return button
    }()
    
    // 전체 컨텐츠를 담는 스택뷰
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            leftRatingContainer,
            rightChartContainer
        ])
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.alignment = .top
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        setupLayout()
        setupActions()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .white
        selectionStyle = .none
        
        contentView.addSubview(menuLabel)
        contentView.addSubview(contentStackView)
        contentView.addSubview(addReviewButton)
        
        leftRatingContainer.addSubview(mainRatingView)
        leftRatingContainer.addSubview(detailRatingView)
        
        rightChartContainer.addSubview(reviewCountView)
        rightChartContainer.addSubview(chartView)
    }
    
    private func setupLayout() {
        menuLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(menuLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        // 왼쪽 컨테이너 내부 레이아웃
        mainRatingView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        detailRatingView.snp.makeConstraints {
            $0.top.equalTo(mainRatingView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        // 오른쪽 컨테이너 내부 레이아웃
        reviewCountView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        chartView.snp.makeConstraints {
            $0.top.equalTo(reviewCountView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        addReviewButton.snp.makeConstraints {
            $0.top.equalTo(contentStackView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func setupActions() {
        addReviewButton.addTarget(
            self,
            action: #selector(touchAddReviewButton),
            for: .touchUpInside
        )
    }
    
    @objc
    private func touchAddReviewButton() {
        handler?()
    }
}

// MARK: - Data Binding

extension ReviewRateViewCell {
    func dataBind(data: ReviewRateResponse) {
        menuLabel.text = data.menuNames.joined(separator: ", ")
        
        mainRatingView.configure(rating: data.mainRating ?? 0)
        detailRatingView.configure(taste: data.tasteRating, amount: data.amountRating)
        reviewCountView.configure(count: data.totalReviewCount)
        chartView.configure(with: data.reviewRatingCount, total: data.totalReviewCount)
        
        totalRate = data.mainRating ?? 0
    }
    
    func fixMenuDataBind(data: FixedReviewRateResponse) {
        menuLabel.text = data.menuName
        
        mainRatingView.configure(rating: data.mainRating ?? 0)
        detailRatingView.configure(taste: data.tasteRating, amount: data.amountRating)
        reviewCountView.configure(count: data.totalReviewCount)
        chartView.configure(with: data.reviewRatingCount, total: data.totalReviewCount)
        
        totalRate = data.mainRating ?? 0
    }
}

// MARK: - MainRatingView (큰 별점 표시)

private final class MainRatingView: UIView {
    private let starImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.icStarYellow.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 36)
        label.textColor = .black
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [starImageView, ratingLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        starImageView.snp.makeConstraints {
            $0.width.height.equalTo(32)
        }
    }
    
    func configure(rating: Double) {
        ratingLabel.text = String(format: "%.1f", rating)
    }
}

// MARK: - DetailRatingView (맛/양 세부 평점)

private final class DetailRatingView: UIView {
    private let tasteView = RatingItemView(title: "맛")
    private let amountView = RatingItemView(title: "양")
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [tasteView, amountView])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configure(taste: Double?, amount: Double?) {
        if let taste = taste, taste > 0 {
            tasteView.isHidden = false
            tasteView.configure(rating: taste)
        } else {
            tasteView.isHidden = true
        }
        
        if let amount = amount, amount > 0 {
            amountView.isHidden = false
            amountView.configure(rating: amount)
        } else {
            amountView.isHidden = true
        }
    }
}

// MARK: - RatingItemView (맛/양 개별 항목)

private final class RatingItemView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .body3
        label.textColor = .black
        return label
    }()
    
    private let starImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.icStarYellow.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .body2
        label.textColor = EATSSUDesignAsset.Color.Main.primary.color
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, starImageView, ratingLabel])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }()
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        starImageView.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
    }
    
    func configure(rating: Double) {
        ratingLabel.text = String(format: "%.1f", rating)
    }
}

// MARK: - ReviewCountView (총 리뷰 수)

private final class ReviewCountView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "총 리뷰 수"
        label.font = .caption2
        label.textColor = .black
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .caption1
        label.textColor = EATSSUDesignAsset.Color.Main.primary.color
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, countLabel])
        stack.axis = .horizontal
        stack.spacing = 7
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configure(count: Int) {
        countLabel.text = "\(count)"
    }
}

// MARK: - RatingChartView (별점 분포 차트)

private final class RatingChartView: UIView {
    private let chartBars: [ChartBarView] = (1...5).reversed().map { ChartBarView(rating: $0) }
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: chartBars)
        stack.axis = .vertical
        stack.spacing = 0
        stack.distribution = .fillEqually
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(90)
        }
    }
    
    func configure(with ratingCount: StarCount, total: Int) {
        let counts = [
            ratingCount.fiveStarCount,
            ratingCount.fourStarCount,
            ratingCount.threeStarCount,
            ratingCount.twoStarCount,
            ratingCount.oneStarCount
        ]
        
        for (index, bar) in chartBars.enumerated() {
            let count = counts[index]
            let ratio = total > 0 ? CGFloat(count) / CGFloat(total) : 0
            bar.configure(ratio: ratio)
        }
    }
}

// MARK: - ChartBarView (개별 차트 바)

private final class ChartBarView: UIView {
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .black
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private let barView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray300
        view.layer.cornerRadius = 4
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        return view
    }()
    
    private var barWidthConstraint: Constraint?
    
    init(rating: Int) {
        super.init(frame: .zero)
        ratingLabel.text = "\(rating)점"
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(ratingLabel)
        addSubview(barView)
        
        ratingLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(30)
        }
        
        barView.snp.makeConstraints {
            $0.leading.equalTo(ratingLabel.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(10)
            self.barWidthConstraint = $0.width.equalTo(0).constraint
        }
    }
    
    func configure(ratio: CGFloat) {
        let maxWidth: CGFloat = 120
        let width = maxWidth * ratio
        barWidthConstraint?.update(offset: max(0, width))
    }
}
