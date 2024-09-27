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
        $0.text = TextLiteral.Home.todayMenu
        $0.font = .body2
//        $0.backgroundColor = .red
    }
    
    private let priceLabel = UILabel().then {
        $0.text = TextLiteral.Home.price
        $0.font = .body2
        $0.textAlignment = .center
//        $0.backgroundColor = .blue
    }
    
    private let ratingLabel = UILabel().then {
        $0.text = TextLiteral.Home.rating
        $0.font = .body2
        $0.textAlignment = .center
//        $0.backgroundColor = .green
    }
    
    private let lineView = UIView().then {
        $0.backgroundColor = .gray200
    }
    
    lazy var infoTableStackView = UIStackView().then {
        $0.addArrangedSubviews([nameLabel, 
                                priceLabel, 
                                ratingLabel])
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 24
    }
    
    // MARK: - Functions
    
    override func configureUI() {
        super.configureUI()
        contentView.addSubviews(infoTableStackView,
                                lineView)
    }
    
    override func setLayout() {
        infoTableStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.horizontalEdges.equalToSuperview().inset(12)
        }
        nameLabel.snp.makeConstraints {
            $0.width.equalTo(210)
        }
        priceLabel.snp.makeConstraints {
            $0.width.equalTo(47)
        }
        ratingLabel.snp.makeConstraints {
            $0.width.equalTo(25)
        }
        lineView.snp.makeConstraints {
            $0.top.equalTo(infoTableStackView.snp.bottom).offset(11)
            $0.horizontalEdges.equalToSuperview().inset(8)
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview()
        }
    }
}
