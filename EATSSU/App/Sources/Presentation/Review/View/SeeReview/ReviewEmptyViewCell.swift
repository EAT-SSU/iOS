//
//  ReviewEmptyViewCell.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/11/26.
//

import UIKit

import SnapKit

import EATSSUDesign

final class ReviewEmptyViewCell: UITableViewCell {
    // MARK: - Properties

    static let identifier = "ReviewEmptyViewCell"

    // MARK: - UI Components

    private lazy var reviewIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.reviewIcon.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var mainLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 작성된 리뷰가 없어요!"
        label.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 16)
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray600.color
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subLabel: UILabel = {
        let label = UILabel()
        label.text = "메뉴에 가장 먼저 리뷰를 남겨주세요"
        label.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 12)
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray600.color
        label.textAlignment = .center
        return label
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [reviewIconImageView, mainLabel, subLabel])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center
        return stackView
    }()

    // MARK: - Functions

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(contentStackView)
        setLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setLayout() {
        reviewIconImageView.snp.makeConstraints {
            $0.width.height.equalTo(48)
        }
        
        contentStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    func configure(isTokenExist: Bool) {
        if isTokenExist {
            mainLabel.text = "아직 작성된 리뷰가 없어요!"
            subLabel.text = "메뉴에 가장 먼저 리뷰를 남겨주세요"
        } else {
            mainLabel.text = "로그인이 필요합니다"
            subLabel.text = "로그인 후 리뷰를 확인하세요"
        }
    }
}
