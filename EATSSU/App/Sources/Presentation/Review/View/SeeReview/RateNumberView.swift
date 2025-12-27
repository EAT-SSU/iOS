//
//  RateNumberView.swift
//  EatSSU-iOS
//
//  Created by 한금준 on 2025/10/04.
//

import UIKit
import SnapKit

import EATSSUDesign

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

    override func configureUI() {
        addSubviews(rateNumberStackView)
  
        starImageViews = (0..<5).map { _ in
            let imageView = UIImageView()
            imageView.image = emptyStarImage
            return imageView
        }
 
        starsStackView.axis = .horizontal
        starsStackView.spacing = 3
        starsStackView.alignment = .bottom
        starImageViews.forEach { starsStackView.addArrangedSubview($0) }

        rateNumberStackView.axis = .horizontal
        rateNumberStackView.spacing = 6
        rateNumberStackView.alignment = .bottom
    }

    override func setLayout() {
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
