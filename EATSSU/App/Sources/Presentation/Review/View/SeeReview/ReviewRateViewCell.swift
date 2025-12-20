//
//  ReviewRateViewCell.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/11/26.
//

import UIKit
import SnapKit

import EATSSUDesign

// MARK: - ReviewRateViewCell

/// 메뉴 정보와 별점 통계를 표시하는 셀
final class ReviewRateViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "ReviewRateViewCell"
    
    /// 리뷰 작성 버튼 탭 핸들러
    var handler: (() -> Void)?
    
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
        label.text = "김치볶음밥 & 계란국"
        label.font = .header2
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
        label.text = "오늘의 메뉴"
        label.font = .body1
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
        label.font = .bold(size: 36)
        label.textColor = .black
        return label
    }()
    
    // MARK: - UI Components - Rating Chart
    
    /// 별점별 레이블들
    private let fivePointLabel = ReviewRateViewCell.makePointLabel("5점")
    private let fourPointLabel = ReviewRateViewCell.makePointLabel("4점")
    private let threePointLabel = ReviewRateViewCell.makePointLabel("3점")
    private let twoPointLabel = ReviewRateViewCell.makePointLabel("2점")
    private let onePointLabel = ReviewRateViewCell.makePointLabel("1점")
    
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
    
    /// UI 컴포넌트 설정
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
        
        // 서브뷰 추가
        contentView.addSubviews(menuContainer, rateSectionContainer)
        menuContainer.addSubviews(menuTitleStackView, menuLabel)
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
    
    /// 레이아웃 제약조건 설정
    func setLayout() {
        // 메뉴 컨테이너
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
        
        // 별점 섹션
        rateSectionContainer.snp.makeConstraints { make in
            make.top.equalTo(menuLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(60)
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
        
        // 차트 바들
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
        
        // 포인트 레이블 높이
        for item in [onePointLabel, twoPointLabel, threePointLabel, fourPointLabel, fivePointLabel] {
            item.snp.makeConstraints {
                $0.height.equalTo(18.adjusted)
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// 식사(Meal) 통계 데이터로 셀 구성
    /// - Parameter data: 식사 통계 응답 데이터
    func configureWithMealStatistics(_ data: ReviewMealStatisticsResponse) {
        let menuNames = data.menuList.map { $0.name }
        menuLabel.text = menuNames.joined(separator: " + ")
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
