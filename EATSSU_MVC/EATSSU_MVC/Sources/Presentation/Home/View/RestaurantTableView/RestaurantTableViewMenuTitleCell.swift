//
//  RestaurantTableViewMenuTitleCell.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/08/09.
//

import UIKit

class RestaurantTableViewMenuTitleCell: BaseTableViewCell {
    
    // MARK:  - Properties
    
    static let identifier = "RestaurantTableViewMenuTitleCell"
    
    // MARK: - UI Components
    
    private let nameLabel = UILabel().then {
        $0.text = TextLiteral.menu
        $0.font = .body2
    }
    
    private let priceLabel = UILabel().then {
        $0.text = TextLiteral.price
        $0.font = .body2
    }
    
    private let ratingLabel = UILabel().then {
        $0.text = TextLiteral.rating
        $0.font = .body2
    }
    
    private let lineView = UIView().then {
        $0.backgroundColor = .gray200
    }
    
    lazy var infoTableStackView = UIStackView().then {
        $0.addArrangedSubviews([nameLabel, 
                                priceLabel, 
                                ratingLabel])
        $0.axis = .horizontal
        $0.setCustomSpacing(35, after: priceLabel)
    }
    
    // MARK: - Functions
    
    override func configureUI() {
        super.configureUI()
        contentView.addSubviews(infoTableStackView,
                                lineView)
    }
    
    override func setLayout() {
        infoTableStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.leading.equalToSuperview().inset(15)
            $0.trailing.equalToSuperview().inset(32)
        }
        lineView.snp.makeConstraints {
            $0.top.equalTo(infoTableStackView.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(8)
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview()
        }
    }
}
