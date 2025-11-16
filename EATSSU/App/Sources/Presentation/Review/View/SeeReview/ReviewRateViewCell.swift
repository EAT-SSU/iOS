//
//  ReviewRateViewCell.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/11/26.
//

import UIKit
import SnapKit
import EATSSUDesign

final class ReviewRateViewCell: UITableViewCell {
    // MARK: - Properties

    static let identifier = "ReviewRateViewCell"
    var handler: (() -> Void)?
    var totalRate: Double = 0
    var reviewData: ReviewRateResponse?

    // MARK: - UI Components
    
    private let menuContainer: UIView = {
        let view = UIView()
        view.backgroundColor = EATSSUDesignAsset.Color.GrayScale.gray100.color
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private var menuLabel: UILabel = {
        let label = UILabel()
        label.text = "김치볶음밥 & 계란국"
        label.font = .header2
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let menuIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.icRestaurant.image
        return imageView
    }()

    private let menuTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘의 메뉴"
        label.font = .body1
        label.textColor = .black
        return label
    }()

    private lazy var menuTitleStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [menuIcon, menuTitleLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        return stack
    }()

    private let rateSectionContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private let bigStarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.icStarYellow.image
        return imageView
    }()

    private let rateNumLabel: UILabel = {
        let label = UILabel()
        label.text = "4.3"
        label.font = .bold(size: 36)
        label.textColor = .black
        return label
    }()

    private let fivePointLabel = ReviewRateViewCell.makePointLabel("5점")
    private let fourPointLabel = ReviewRateViewCell.makePointLabel("4점")
    private let threePointLabel = ReviewRateViewCell.makePointLabel("3점")
    private let twoPointLabel = ReviewRateViewCell.makePointLabel("2점")
    private let onePointLabel = ReviewRateViewCell.makePointLabel("1점")

    // Chart bar containers and foregrounds
    private var oneChartBar: UIView!
    private var twoChartBar: UIView!
    private var threeChartBar: UIView!
    private var fourChartBar: UIView!
    private var fiveChartBar: UIView!
    
    private var oneForeground: UIView!
    private var twoForeground: UIView!
    private var threeForeground: UIView!
    private var fourForeground: UIView!
    private var fiveForeground: UIView!

    lazy var yAxisStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [fivePointLabel,
                                                       fourPointLabel,
                                                       threePointLabel,
                                                       twoPointLabel,
                                                       onePointLabel])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .trailing
        return stackView
    }()

    lazy var totalRateStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [bigStarImageView,
                                                       rateNumLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8.adjusted
        stackView.alignment = .center
        return stackView
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
        setLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helper

    private static func makePointLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .caption2
        label.textColor = .black
        return label
    }

    // MARK: - UI Setup

    func configureUI() {
        // Helper to create chart bar with background and foreground
        func makeChartBar() -> (container: UIView, foreground: UIView) {
            let container = UIView()
            container.backgroundColor = .gray200
            container.layer.cornerRadius = 5
            container.layer.masksToBounds = true
            let foreground = UIView()
            foreground.backgroundColor = EATSSUDesignAsset.Color.Main.primary.color
            foreground.layer.cornerRadius = 5
            foreground.layer.masksToBounds = true
            container.addSubview(foreground)
            foreground.snp.makeConstraints { make in
                make.leading.top.bottom.equalToSuperview()
                make.width.equalTo(0)
            }
            return (container, foreground)
        }

        let oneBar = makeChartBar()
        oneChartBar = oneBar.container
        oneForeground = oneBar.foreground
        let twoBar = makeChartBar()
        twoChartBar = twoBar.container
        twoForeground = twoBar.foreground
        let threeBar = makeChartBar()
        threeChartBar = threeBar.container
        threeForeground = threeBar.foreground
        let fourBar = makeChartBar()
        fourChartBar = fourBar.container
        fourForeground = fourBar.foreground
        let fiveBar = makeChartBar()
        fiveChartBar = fiveBar.container
        fiveForeground = fiveBar.foreground

        contentView.addSubviews(
            menuContainer,
            rateSectionContainer
        )

        menuContainer.addSubviews(menuTitleStackView, menuLabel)

        rateSectionContainer.addSubviews(totalRateStackView, yAxisStackView,
                                         oneChartBar, twoChartBar, threeChartBar, fourChartBar, fiveChartBar)

        totalRateStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().offset(35.5)
            make.leading.equalToSuperview().offset(36)
        }

        yAxisStackView.snp.makeConstraints { make in
            make.leading.equalTo(totalRateStackView.snp.trailing).offset(36)
            make.centerY.equalTo(totalRateStackView)
        }
    }

    func setLayout() {
        backgroundColor = .white

        menuContainer.snp.makeConstraints { make in
//            make.top.equalTo(safeAreaLayoutGuide.snp.topMargin).offset(10)
            make.top.equalTo(contentView.snp.top).offset(0)
            make.centerX.equalToSuperview()
            make.width.equalTo(320.adjusted)
            make.height.greaterThanOrEqualTo(100)
        }
        
        menuTitleStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
        }
        
        menuIcon.snp.makeConstraints { make in
            make.width.height.equalTo(20)
        }

        menuLabel.snp.makeConstraints { make in
            make.top.equalTo(menuTitleStackView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(28)
            make.bottom.equalToSuperview().inset(16)
        }
        
        rateSectionContainer.snp.makeConstraints { make in
            make.top.equalTo(menuLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(60)
        }

        oneChartBar.snp.makeConstraints { make in
            make.centerY.equalTo(onePointLabel)
            make.leading.equalTo(onePointLabel.snp.trailing).offset(7)
            make.height.equalTo(10)
            make.width.equalTo(126)
        }

        twoChartBar.snp.makeConstraints { make in
            make.centerY.equalTo(twoPointLabel)
            make.leading.equalTo(twoPointLabel.snp.trailing).offset(7)
            make.height.equalTo(10)
            make.width.equalTo(126)
        }

        threeChartBar.snp.makeConstraints { make in
            make.centerY.equalTo(threePointLabel)
            make.leading.equalTo(threePointLabel.snp.trailing).offset(7)
            make.height.equalTo(10)
            make.width.equalTo(126)
        }

        fourChartBar.snp.makeConstraints { make in
            make.centerY.equalTo(fourPointLabel)
            make.leading.equalTo(fourPointLabel.snp.trailing).offset(7)
            make.height.equalTo(10)
            make.width.equalTo(126)
        }

        fiveChartBar.snp.makeConstraints { make in
            make.centerY.equalTo(fivePointLabel)
            make.leading.equalTo(fivePointLabel.snp.trailing).offset(7)
            make.height.equalTo(10)
            make.width.equalTo(126)
        }

        for item in [onePointLabel, twoPointLabel, threePointLabel, fourPointLabel, fivePointLabel] {
            item.snp.makeConstraints {
                $0.height.equalTo(18.adjusted)
            }
        }

        bigStarImageView.snp.makeConstraints {
            $0.height.width.equalTo(24.adjusted)
        }
    }

    @objc
    func touchAddReviewButton() {
        handler?()
    }
}

extension ReviewRateViewCell {
    func fixMenuDataBind(data: FixedReviewRateResponse) {
//        let total = String(format: "%.1f", data.mainRating ?? 0)
        let ratingValue = data.mainRating ?? 0
        if ratingValue == 0.0 {
            rateNumLabel.text = "-"
        } else {
            let total = String(format: "%.1f", ratingValue)
            rateNumLabel.text = "\(total)"
        }
        menuLabel.text = data.menuName
//        rateNumLabel.text = "\(total)"
//        totalRate = data.mainRating ?? 0
        totalRate = ratingValue

        fiveForeground.snp.updateConstraints {
            $0.width.equalTo(126 * data.reviewRatingCount.fiveStarCount / max(data.totalReviewCount, 1))
        }
        fourForeground.snp.updateConstraints {
            $0.width.equalTo(126 * data.reviewRatingCount.fourStarCount / max(data.totalReviewCount, 1))
        }
        threeForeground.snp.updateConstraints {
            $0.width.equalTo(126 * data.reviewRatingCount.threeStarCount / max(data.totalReviewCount, 1))
        }
        twoForeground.snp.updateConstraints {
            $0.width.equalTo(126 * data.reviewRatingCount.twoStarCount / max(data.totalReviewCount, 1))
        }
        oneForeground.snp.updateConstraints {
            $0.width.equalTo(126 * data.reviewRatingCount.oneStarCount / max(data.totalReviewCount, 1))
        }
    }

    func dataBind(data: ReviewRateResponse) {
//        let total = String(format: "%.1f", data.mainRating ?? 0)
        let ratingValue = data.mainRating ?? 0
        if ratingValue == 0.0 {
            rateNumLabel.text = "-"
        } else {
            let total = String(format: "%.1f", ratingValue)
            rateNumLabel.text = "\(total)"
        }
        menuLabel.text = data.menuNames.joined(separator: " + ")
//        rateNumLabel.text = "\(total)"
//        totalRate = data.mainRating ?? 0
        totalRate = ratingValue

        fiveForeground.snp.updateConstraints {
            $0.width.equalTo(126 * data.reviewRatingCount.fiveStarCount / max(data.totalReviewCount, 1))
        }
        fourForeground.snp.updateConstraints {
            $0.width.equalTo(126 * data.reviewRatingCount.fourStarCount / max(data.totalReviewCount, 1))
        }
        threeForeground.snp.updateConstraints {
            $0.width.equalTo(126 * data.reviewRatingCount.threeStarCount / max(data.totalReviewCount, 1))
        }
        twoForeground.snp.updateConstraints {
            $0.width.equalTo(126 * data.reviewRatingCount.twoStarCount / max(data.totalReviewCount, 1))
        }
        oneForeground.snp.updateConstraints {
            $0.width.equalTo(126 * data.reviewRatingCount.oneStarCount / max(data.totalReviewCount, 1))
        }
    }
}
