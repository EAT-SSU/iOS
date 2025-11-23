//
//  ReviewDividerCell.swift
//  EATSSU
//
//  Created by 한금준 on 10/4/25.
//

import SnapKit
import UIKit

import EATSSUDesign

final class ReviewDividerCell: UITableViewCell {
    static let identifier = "ReviewDividerCell"
    
    private let divider: UIView = {
        let divider = UIView()
        divider.backgroundColor = .gray100
        return divider
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "리뷰 15"
        label.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 16)
        label.textColor = .black
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(divider)
        contentView.addSubview(label)
        
        divider.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(12)
        }
        label.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().inset(8)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(reviewCount: Int) {
        let text = "리뷰 \(reviewCount)"
        let attributed = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: "\(reviewCount)")
        attributed.addAttribute(.foregroundColor, value: EATSSUDesignAsset.Color.Main.primary.color, range: range)
        label.attributedText = attributed
    }
}
