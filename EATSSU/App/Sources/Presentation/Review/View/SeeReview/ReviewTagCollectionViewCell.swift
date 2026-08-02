//
//  ReviewTagCollectionViewCell.swift
//  EATSSU
//
//  Created by 한금준 on 10/3/25.
//

import UIKit
import SnapKit

import EATSSUDesign

final class ReviewTagCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "ReviewTagCollectionViewCell"
    
    // MARK: - UI Components
    
    /// 좋아요 아이콘
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = EATSSUDesignAsset.Images.thumbUp.image
        iv.isHidden = true
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    /// 태그 이름 레이블
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .primary
        label.numberOfLines = 1
        label.lineBreakMode = .byClipping
        label.adjustsFontSizeToFitWidth = false
        return label
    }()
    
    /// 아이콘과 레이블을 담는 스택뷰
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 4
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = contentView.bounds.height / 2
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var newFrame = layoutAttributes.frame
        newFrame.size.width = ceil(size.width)
        newFrame.size.height = ceil(size.height)
        layoutAttributes.frame = newFrame
        
        return layoutAttributes
    }
    
    // MARK: - UI Configuration

    private func setupViews() {
        contentView.backgroundColor = UIColor.secondary
        contentView.layer.borderColor = UIColor.primary.cgColor
        contentView.layer.borderWidth = 1

        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        iconImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        iconImageView.setContentHuggingPriority(.required, for: .horizontal)

        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        contentView.addSubview(stackView)

        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(12)
        }

        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().inset(8)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().inset(5)
        }

        contentView.snp.makeConstraints { make in
            make.height.equalTo(26)
        }
    }
    
    // MARK: - Public Methods
    
    /// 태그 데이터로 셀 구성
    /// - Parameters:
    ///   - tagName: 태그 이름
    ///   - isLiked: 좋아요 여부
    func configure(tagName: String, isLiked: Bool) {
        titleLabel.text = tagName
        
        if isLiked {
            iconImageView.isHidden = false
            iconImageView.image = EATSSUDesignAsset.Images.thumbUp.image
        } else {
            iconImageView.isHidden = true
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    static func estimatedSize(for text: String, isLiked: Bool, maxWidth: CGFloat) -> CGSize {
        let label = UILabel()
        label.font = .caption2
        label.text = text
        label.numberOfLines = 1

        let labelSize = label.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))

        let iconWidth: CGFloat = isLiked ? 14 : 0
        let totalWidth = labelSize.width + iconWidth + 16
        let height: CGFloat = 26

        return CGSize(width: ceil(totalWidth), height: height)
    }
}
