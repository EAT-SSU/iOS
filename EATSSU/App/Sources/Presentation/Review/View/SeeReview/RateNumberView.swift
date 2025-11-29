//
//  RateNumberView.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/06/29.
//

import UIKit
import SnapKit

import EATSSUDesign

// MARK: - RateNumberView

/// 별점을 시각적으로 표시하는 커스텀 뷰
final class RateNumberView: BaseUIView {
    
    // MARK: - Properties
    
    /// 채워진 별 이미지
    var filledStarImage: UIImage? = EATSSUDesignAsset.Images.icStarYellow.image
    
    /// 빈 별 이미지
    var emptyStarImage: UIImage? = EATSSUDesignAsset.Images.icStarGray.image
    
    // MARK: - UI Components
    
    /// 별 이미지뷰 배열 (5개)
    private var starImageViews: [UIImageView] = []
    
    /// 별들을 가로로 배치하는 스택뷰
    private lazy var starsStackView = UIStackView()
    
    /// 전체 레이팅 컴포넌트를 담는 스택뷰
    private lazy var rateNumberStackView = UIStackView(arrangedSubviews: [starsStackView])
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: - UI Configuration
    
    /// UI 컴포넌트 설정
    override func configureUI() {
        addSubviews(rateNumberStackView)
        
        // 5개의 별 이미지뷰 생성
        starImageViews = (0..<5).map { _ in
            let imageView = UIImageView()
            imageView.image = emptyStarImage
            return imageView
        }
        
        // 별 스택뷰 설정
        starsStackView.axis = .horizontal
        starsStackView.spacing = 3
        starsStackView.alignment = .bottom
        starImageViews.forEach { starsStackView.addArrangedSubview($0) }
        
        // 전체 레이팅 스택뷰 설정
        rateNumberStackView.axis = .horizontal
        rateNumberStackView.spacing = 6
        rateNumberStackView.alignment = .bottom
    }
    
    /// 레이아웃 제약조건 설정
    override func setLayout() {
        // 각 별의 크기 설정
        starImageViews.forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(12.adjusted)
                $0.width.equalTo(12.adjusted)
            }
        }
        
        // 전체 스택뷰 제약조건
        rateNumberStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - Public Methods
    
    /// 별점 설정 (1~5점)
    /// - Parameter rating: 표시할 별점 (1-5)
    func setRating(_ rating: Int) {
        for (index, star) in starImageViews.enumerated() {
            if index < rating {
                star.image = filledStarImage
            } else {
                star.image = emptyStarImage
            }
        }
    }
}
