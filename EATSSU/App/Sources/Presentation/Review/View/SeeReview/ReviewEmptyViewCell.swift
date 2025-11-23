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
    private lazy var noReviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = EATSSUDesignAsset.Color.GrayScale.gray600.color
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 작성된 리뷰가 없어요"
        label.font = .subtitle2
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray600.color
        label.textAlignment = .center
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "메뉴에 가장 먼저 리뷰를 남겨주세요!"
        label.font = .caption2
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray600.color
        label.textAlignment = .center
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [noReviewImageView, titleLabel, descriptionLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        return stack
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(stackView)
        setLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
    private func setLayout() {
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        noReviewImageView.snp.makeConstraints {
            $0.size.equalTo(48)
        }
    }

    // MARK: - Configure
    func configure(isTokenExist: Bool) {
        if isTokenExist {
            noReviewImageView.image = EATSSUDesignAsset.Images.noReview.image
            titleLabel.text = "아직 작성된 리뷰가 없어요"
            descriptionLabel.text = "메뉴에 가장 먼저 리뷰를 남겨주세요!"
        } else {
            noReviewImageView.image = ImageLiteral.pleaseLogin
        }
    }
}
