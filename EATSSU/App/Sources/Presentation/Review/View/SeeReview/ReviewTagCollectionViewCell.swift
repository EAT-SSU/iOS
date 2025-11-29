//
//  ReviewTagCollectionViewCell.swift
//  EATSSU
//
//  Created by 한금준 on 10/3/25.
//

import UIKit
import SnapKit

// MARK: - ReviewTagCollectionViewCell

/// 리뷰의 메뉴 태그를 표시하는 컬렉션뷰 셀
final class ReviewTagCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "ReviewTagCollectionViewCell"
    
    // MARK: - UI Components
    
    /// 좋아요 아이콘
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "hand.thumbsup")
        iv.tintColor = .systemTeal
        iv.isHidden = true
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    /// 태그 이름 레이블
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = .systemTeal
        return label
    }()
    
    /// 아이콘과 레이블을 담는 스택뷰
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 4
        sv.alignment = .center
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
    
    // MARK: - UI Configuration
    
    /// UI 컴포넌트 설정
    private func setupViews() {
        // 배경 및 테두리 설정
        contentView.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.1)
        contentView.layer.borderColor = UIColor.systemTeal.cgColor
        contentView.layer.borderWidth = 1
        
        // 스택뷰 구성
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        contentView.addSubview(stackView)
        
        // 레이아웃 설정
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(10)
        }
        
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().inset(8)
            make.top.equalToSuperview().offset(2)
            make.bottom.equalToSuperview().inset(2)
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
            iconImageView.image = UIImage(systemName: "hand.thumbsup")
        } else {
            iconImageView.isHidden = true
        }
    }
}
