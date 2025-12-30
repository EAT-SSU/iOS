//
//  ReviewEmptyViewCell.swift
//  EatSSU-iOS
//
//  Created by 한금준 on 10/4/25.
//

import UIKit
import SnapKit

import EATSSUDesign

final class ReviewEmptyViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "ReviewEmptyViewCell"
    
    // MARK: - UI Components
    
    /// 빈 상태 이미지
    private lazy var noReviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = EATSSUDesignAsset.Color.GrayScale.gray600.color
        return imageView
    }()
    
    /// 제목 레이블
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .subtitle2
        label.text = "아직 작성된 리뷰가 없어요!"
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray600.color
        label.textAlignment = .center
        return label
    }()
    
    /// 설명 레이블
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "메뉴에 가장 먼저 리뷰를 남겨주세요!"
        label.font = .caption2
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray600.color
        label.textAlignment = .center
        return label
    }()
    
    /// 컴포넌트들을 세로로 배치하는 스택뷰
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            noReviewImageView,
            titleLabel,
            descriptionLabel
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        return stack
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Configuration

    private func setupUI() {
        contentView.addSubview(stackView)
    }

    private func setLayout() {
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        noReviewImageView.snp.makeConstraints {
            $0.size.equalTo(48)
        }
    }
    
    // MARK: - Public Methods
    
    /// 토큰 존재 여부에 따라 셀 구성
    /// - Parameter isTokenExist: 로그인 토큰 존재 여부
    func configure(isTokenExist: Bool) {
        if isTokenExist {
            noReviewImageView.image = EATSSUDesignAsset.Images.noReview.image
            titleLabel.text = "아직 작성된 리뷰가 없어요"
            descriptionLabel.text = "메뉴에 가장 먼저 리뷰를 남겨주세요!"
        } else {
            titleLabel.text = "로그인이 필요합니다"
            descriptionLabel.text = "로그인 후 리뷰를 확인하세요"
        }
    }
    
    /// 마이페이지용 빈 상태 구성
    func configureForMyReview() {
        titleLabel.text = "아직 작성한 리뷰가 없어요"
        descriptionLabel.text = "첫 리뷰를 남겨 주세요!"
    }
}
