//
//  ReviewRateViewCell.swift
//  EatSSU-iOS
//
//  Created by 한금준 on 10/4/25.
//

import UIKit
import SnapKit

import EATSSUDesign

final class ReviewRateViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "ReviewRateViewCell"
    
    /// 리뷰 작성 버튼 탭 핸들러
    var handler: (() -> Void)?

    /// "오늘의 메뉴를 찜해보세요!" 탭 핸들러
    var onTapTodayMenuFavorite: (() -> Void)?

    /// 찜 버튼이 보일 때 셀에 더해지는 높이 (버튼 위 12.5 + 버튼 41). 디자인 기준
    static let todayMenuFavoriteExtraHeight: CGFloat = 53.5

    private var rateSectionTopConstraint: Constraint?
    
    /// 전체 평균 별점
    var totalRate: Double = 0
    
    // MARK: - UI Components - Menu Section
    
    /// 메뉴 정보 컨테이너
    private let menuContainer: UIView = {
        let view = UIView()
        view.backgroundColor = EATSSUDesignAsset.Color.GrayScale.gray100.color
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    /// 메뉴 이름 레이블
    var menuLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .body1
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    /// 메뉴 아이콘
    private let menuIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.icRestaurant.image
        return imageView
    }()
    
    /// "오늘의 메뉴" 타이틀 레이블
    private let menuTitleLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.Review.todayMenu
        label.font = .subtitle2
        label.textColor = .black
        return label
    }()
    
    /// 메뉴 타이틀 섹션 스택뷰
    private lazy var menuTitleStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [menuIcon, menuTitleLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        return stack
    }()
    
    // MARK: - UI Components - Today Menu Favorite

    /// 오늘 식단일 때만 보이는 찜 탭 이동 버튼. 디자인: 높이 41, 모서리 8, gray300 테두리, 하트(좌 11) · Medium 12 · 화살표(우 14)
    private let todayMenuFavoriteButton: UIControl = {
        let control = UIControl()
        control.backgroundColor = .white
        control.layer.cornerRadius = 8
        control.layer.borderWidth = 1
        control.layer.borderColor = UIColor.gray300.cgColor
        control.isHidden = true
        // 하위 라벨 대신 버튼 하나로 읽히게 한다 (VoiceOver · UI 테스트)
        control.isAccessibilityElement = true
        control.accessibilityTraits = .button
        control.accessibilityLabel = TextLiteral.Review.todayMenuFavoritePrompt
        control.accessibilityIdentifier = "review.todayMenuFavoriteButton"
        return control
    }()

    private let favoriteHeartImageView: UIImageView = {
        let imageView = UIImageView(image: EATSSUDesignAsset.Images.icLikeLine.image)
        imageView.tintColor = .gray400
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let favoriteTitleLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.Review.todayMenuFavoritePrompt
        label.font = .caption2
        label.textColor = .gray700
        return label
    }()

    private let favoriteChevronImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: config))
        imageView.tintColor = .gray400
        imageView.contentMode = .center
        return imageView
    }()

    // MARK: - UI Components - Rating Section
    
    /// 별점 섹션 컨테이너
    private let rateSectionContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    /// 큰 별 아이콘
    private let bigStarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.icStarYellow.image
        return imageView
    }()
    
    /// 평균 별점 숫자 레이블
    var rateNumLabel: UILabel = {
        let label = UILabel()
        label.text = "4.3"
        label.font = .rate
        label.textColor = .black
        return label
    }()
    
    // MARK: - UI Components - Rating Chart
    
    /// 별점별 레이블들
    private let fivePointLabel = ReviewRateViewCell.makePointLabel(TextLiteral.Review.fiveStars)
    private let fourPointLabel = ReviewRateViewCell.makePointLabel(TextLiteral.Review.fourStars)
    private let threePointLabel = ReviewRateViewCell.makePointLabel(TextLiteral.Review.threeStars)
    private let twoPointLabel = ReviewRateViewCell.makePointLabel(TextLiteral.Review.twoStars)
    private let onePointLabel = ReviewRateViewCell.makePointLabel(TextLiteral.Review.oneStar)
    
    /// 차트 바 컨테이너들
    var oneChartBar: UIView!
    var twoChartBar: UIView!
    var threeChartBar: UIView!
    var fourChartBar: UIView!
    var fiveChartBar: UIView!
    
    /// 차트 바 전경(채워지는 부분)들
    var oneForeground: UIView!
    var twoForeground: UIView!
    var threeForeground: UIView!
    var fourForeground: UIView!
    var fiveForeground: UIView!
    
    /// Y축(별점) 레이블 스택뷰
    lazy var yAxisStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            fivePointLabel,
            fourPointLabel,
            threePointLabel,
            twoPointLabel,
            onePointLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .trailing
        return stackView
    }()
    
    /// 전체 별점 표시 스택뷰
    lazy var totalRateStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            bigStarImageView,
            rateNumLabel
        ])
        stackView.axis = .horizontal
        stackView.spacing = 8.adjusted
        stackView.alignment = .center
        return stackView
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Today Menu Favorite

    /// 오늘 식단의 리뷰 화면에서만 찜 탭 이동 버튼을 보여준다
    func setTodayMenuFavoriteButtonVisible(_ visible: Bool) {
        todayMenuFavoriteButton.isHidden = !visible
        rateSectionTopConstraint?.deactivate()
        rateSectionContainer.snp.makeConstraints { make in
            if visible {
                rateSectionTopConstraint = make.top.equalTo(todayMenuFavoriteButton.snp.bottom).offset(24).constraint
            } else {
                rateSectionTopConstraint = make.top.equalTo(menuContainer.snp.bottom).offset(24).constraint
            }
        }
    }

    @objc private func didTapTodayMenuFavorite() {
        onTapTodayMenuFavorite?()
    }

    // MARK: - Helper Methods
    
    /// 별점 레이블 생성 헬퍼
    /// - Parameter text: 레이블 텍스트
    /// - Returns: 설정된 UILabel
    private static func makePointLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .caption2
        label.textColor = .black
        return label
    }
    
    /// 차트 바 생성 헬퍼
    /// - Returns: 차트 바 컨테이너와 전경 뷰 튜플
    private func makeChartBar() -> (container: UIView, foreground: UIView) {
        let container = UIView()
        container.backgroundColor = .gray200
        container.layer.cornerRadius = 2
        container.layer.masksToBounds = true
        
        let foreground = UIView()
        foreground.backgroundColor = EATSSUDesignAsset.Color.Main.primary.color
        foreground.layer.cornerRadius = 2
        foreground.layer.masksToBounds = true
        
        container.addSubview(foreground)
        foreground.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(0)
        }
        
        return (container, foreground)
    }
    
    // MARK: - UI Configuration

    func configureUI() {
        backgroundColor = .white
        
        // 차트 바들 생성
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

        contentView.addSubviews(menuContainer, todayMenuFavoriteButton, rateSectionContainer)
        menuContainer.addSubviews(menuTitleStackView, menuLabel)
        todayMenuFavoriteButton.addSubviews(favoriteHeartImageView, favoriteTitleLabel, favoriteChevronImageView)
        todayMenuFavoriteButton.addTarget(self, action: #selector(didTapTodayMenuFavorite), for: .touchUpInside)
        rateSectionContainer.addSubviews(
            totalRateStackView,
            yAxisStackView,
            oneChartBar,
            twoChartBar,
            threeChartBar,
            fourChartBar,
            fiveChartBar
        )
    }

    func setLayout() {
        menuContainer.snp.makeConstraints { make in
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

        todayMenuFavoriteButton.snp.makeConstraints { make in
            make.top.equalTo(menuContainer.snp.bottom).offset(12.5)
            make.leading.trailing.equalTo(menuContainer)
            make.height.equalTo(41)
        }
        favoriteHeartImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(11)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
        favoriteTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(33)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(favoriteChevronImageView.snp.leading).offset(-8)
        }
        favoriteChevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(14)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }

        rateSectionContainer.snp.makeConstraints { make in
            // 메뉴 박스 아래 24 (찜 버튼이 보이면 버튼 아래 24)
            rateSectionTopConstraint = make.top.equalTo(menuContainer.snp.bottom).offset(24).constraint
            make.centerX.equalToSuperview().offset(16)
            make.width.equalToSuperview().inset(16)
        }
        
        totalRateStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().offset(35.5)
            make.leading.equalToSuperview().offset(36)
        }
        
        bigStarImageView.snp.makeConstraints {
            $0.height.width.equalTo(24.adjusted)
        }
        
        yAxisStackView.snp.makeConstraints { make in
            make.leading.equalTo(totalRateStackView.snp.trailing).offset(36)
            make.centerY.equalTo(totalRateStackView)
        }

        oneChartBar.snp.makeConstraints { make in
            make.centerY.equalTo(onePointLabel)
            make.leading.equalTo(onePointLabel.snp.trailing).offset(7)
            make.height.equalTo(5)
            make.width.equalTo(115)
        }
        
        twoChartBar.snp.makeConstraints { make in
            make.centerY.equalTo(twoPointLabel)
            make.leading.equalTo(twoPointLabel.snp.trailing).offset(7)
            make.height.equalTo(5)
            make.width.equalTo(115)
        }
        
        threeChartBar.snp.makeConstraints { make in
            make.centerY.equalTo(threePointLabel)
            make.leading.equalTo(threePointLabel.snp.trailing).offset(7)
            make.height.equalTo(5)
            make.width.equalTo(115)
        }
        
        fourChartBar.snp.makeConstraints { make in
            make.centerY.equalTo(fourPointLabel)
            make.leading.equalTo(fourPointLabel.snp.trailing).offset(7)
            make.height.equalTo(5)
            make.width.equalTo(115)
        }
        
        fiveChartBar.snp.makeConstraints { make in
            make.centerY.equalTo(fivePointLabel)
            make.leading.equalTo(fivePointLabel.snp.trailing).offset(7)
            make.height.equalTo(5)
            make.width.equalTo(115)
        }

        for item in [onePointLabel, twoPointLabel, threePointLabel, fourPointLabel, fivePointLabel] {
            item.snp.makeConstraints {
                $0.height.equalTo(18.adjusted)
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// 식사(Meal) 통계 데이터로 셀 구성
    /// - Parameters:
    ///   - data: 식사 통계 응답 데이터
    ///   - menuNames: 헤더에 표시할 메뉴 이름 (표시 언어 규칙은 호출부에서 결정)
    func configureWithMealStatistics(_ data: ReviewMealStatisticsResponse, menuNames: [String]) {
        menuLabel.text = menuNames.joined(separator: ", ")
        setRating(data.rating ?? 0)
        updateRatingChart(with: data.reviewRatingCount, totalCount: data.totalReviewCount)
    }
    
    /// 메뉴(Menu) 통계 데이터로 셀 구성
    /// - Parameter data: 메뉴 통계 응답 데이터
    func configureWithMenuStatistics(_ data: ReviewMenuStatisticsResponse) {
        menuLabel.text = data.menuName
        setRating(data.rating ?? 0)
        updateRatingChart(with: data.reviewRatingCount, totalCount: data.totalReviewCount)
    }
    
    // MARK: - Private Methods
    
    /// 평균 별점 설정
    /// - Parameter rating: 별점 값 (0.0 ~ 5.0)
    private func setRating(_ rating: Double) {
        totalRate = rating
        
        if rating == 0.0 {
            rateNumLabel.text = "-"
        } else {
            let formattedRating = String(format: "%.1f", rating)
            rateNumLabel.text = formattedRating
        }
    }
    
    /// 별점별 분포 차트 업데이트
    /// - Parameters:
    ///   - ratingCount: 별점별 개수 데이터
    ///   - totalCount: 전체 리뷰 개수
    private func updateRatingChart(with ratingCount: ReviewRatingCount, totalCount: Int) {
        let safeTotal = max(totalCount, 1)
        
        fiveForeground.snp.updateConstraints {
            $0.width.equalTo(126 * ratingCount.fiveStarCount / safeTotal)
        }
        fourForeground.snp.updateConstraints {
            $0.width.equalTo(126 * ratingCount.fourStarCount / safeTotal)
        }
        threeForeground.snp.updateConstraints {
            $0.width.equalTo(126 * ratingCount.threeStarCount / safeTotal)
        }
        twoForeground.snp.updateConstraints {
            $0.width.equalTo(126 * ratingCount.twoStarCount / safeTotal)
        }
        oneForeground.snp.updateConstraints {
            $0.width.equalTo(126 * ratingCount.oneStarCount / safeTotal)
        }
        
        layoutIfNeeded()
    }
}
