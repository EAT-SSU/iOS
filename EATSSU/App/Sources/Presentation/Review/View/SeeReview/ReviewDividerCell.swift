//
//  ReviewDividerCell.swift
//  EATSSU
//
//  Created by 한금준 on 10/4/25.
//

import UIKit
import SnapKit

import EATSSUDesign

final class ReviewDividerCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "ReviewDividerCell"
    
    // MARK: - UI Components
    
    /// 상단 구분선
    private let divider: UIView = {
        let divider = UIView()
        divider.backgroundColor = .gray100
        return divider
    }()
    
    /// 리뷰 개수 표시 레이블
    private let label: UILabel = {
        let label = UILabel()
        label.text = "리뷰 15"
        label.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 16)
        label.textColor = .black
        return label
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Configuration

    private func setupUI() {
        contentView.addSubview(divider)
        contentView.addSubview(label)
    }

    private func setLayout() {
        divider.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(12)
        }
        
        label.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Public Methods
    
    /// 리뷰 개수로 셀 구성
    /// - Parameter reviewCount: 표시할 리뷰 개수
    func configure(reviewCount: Int) {
        let text = "리뷰 \(reviewCount)"
        let attributed = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: "\(reviewCount)")
        attributed.addAttribute(
            .foregroundColor,
            value: EATSSUDesignAsset.Color.Main.primary.color,
            range: range
        )
        label.attributedText = attributed
    }
}
