//
//  RestaurantTableViewHeader.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/08/09.
//

import UIKit

import SnapKit

class RestaurantTableViewHeader: BaseTableViewHeaderView {
    
    // MARK: - Properties
    
    static let identifier = "RestaurantTableViewHeader"
    var infoButtonDidTappedCallback: (() -> Void)?

    // MARK: - UI Components
    
    let titleLabel = UILabel()
    let infoButton = UIButton()
    let stackView = UIStackView()
    
    // MARK: - Life Cycles
    
    override func configure() {
        super.configure()
        
        configureUI()
        setLayout()
        setViewProperties()
    }
    
    // MARK: - Functions
    
    func setViewProperties() {
        titleLabel.do {
            $0.font = .subtitle1
            $0.text = "기숙사 식당"
        }
        infoButton.do {
            var configuration = UIButton.Configuration.plain()
            configuration.baseForegroundColor = EATSSUAsset.Color.GrayScale.gray600.color
            configuration.image = EATSSUAsset.Images.Version2.icInfo.image
            configuration.imagePlacement = .trailing
            configuration.imagePadding = 4.0
            $0.configuration = configuration
        }
        stackView.do {
            $0.axis = .horizontal
            $0.distribution = .equalSpacing
            $0.alignment = .center
        }
    }
    
    func configureUI() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubviews([titleLabel,
                                       infoButton])
    }
    
    func setLayout() {
        stackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
        }
        infoButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
        }
    }
}
