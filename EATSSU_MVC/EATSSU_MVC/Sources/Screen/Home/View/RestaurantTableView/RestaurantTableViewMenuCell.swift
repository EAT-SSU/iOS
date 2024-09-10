//
//  RestaurantTableViewMenuCell.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/08/09.
//

import UIKit

import SnapKit

class RestaurantTableViewMenuCell: BaseTableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "RestaurantTableViewMenuCell"
    
    var model: MenuTypeInfo? {
        didSet {
            if let model = model {
                bind(model)
            }
        }
    }
    
    // MARK: - UI Components
    
    lazy var menuIDLabel = UILabel()
    lazy var nameLabel = UILabel().then {
        $0.font = .body3
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping 
    }
    lazy var priceLabel = UILabel().then {
        $0.font = .body3
    }
    lazy var ratingLabel = UILabel().then {
        $0.font = .body3
        $0.textAlignment = .center
    }
    
    // MARK: - Life Cycle
    
    override func prepareForReuse() {
        super.prepareForReuse()

        nameLabel.text = nil
        priceLabel.text = nil
        ratingLabel.text = nil
    }
    
    // MARK: - Functions
    
    override func configureUI() {
        super.configureUI()
        contentView.addSubviews(nameLabel,
                                priceLabel,
                                ratingLabel)
    }

    override func setLayout() {
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(contentView.snp.leading).offset(16)
            $0.top.equalTo(contentView.snp.top).offset(11)
            $0.width.equalTo(210)
            $0.bottom.equalTo(contentView.snp.bottom).offset(-5)
        }
        priceLabel.snp.makeConstraints {
            $0.trailing.equalTo(ratingLabel.snp.leading)
            $0.width.equalTo(55)
            $0.centerY.equalTo(nameLabel)
        }
        ratingLabel.snp.makeConstraints {
            $0.trailing.equalTo(contentView.snp.trailing).inset(28)
            $0.width.equalTo(30)
            $0.centerY.equalTo(nameLabel)
        }
    }
    
    func bind(_ model: MenuTypeInfo) {
        switch model {
        case .change(let data):
            priceLabel.text = data.price != nil ? String(data.price!) : ""

            if data.mainRating != nil {
                let formatRating = String(format: "%.1f", data.mainRating ?? 0)
                ratingLabel.text = formatRating
            } else {
                ratingLabel.text = TextLiteral.emptyRating
            }
            
            if data.menusInformationList.isEmpty {
                // vc에서 이미 필터링되어 의미 없음. 리팩 필요
                nameLabel.text = "제공되는 메뉴가 없습니다"
            } else {
                nameLabel.text = data.menusInformationList.map { $0.name }.joined(separator: "+")
            }
        
        case .fix(let data):
            if let price = data.price {
                priceLabel.text = String(price)
                let formatRating = String(format: "%.1f", data.mainRating ?? 0)
                ratingLabel.text = formatRating != "0.0" ? formatRating : "-"
                nameLabel.text = data.name
            } else {
                nameLabel.text = "제공되는 메뉴가 없습니다"
            }
        }
    }
}
