//
//  MenuChipHorizontalScrollView.swift
//  EATSSU-DEV
//
//  Created by 최지우 on 1/30/25.
//

import UIKit

import EATSSUDesign

class MenuChipHorizontalScrollView: BaseUIView {
    
    // MARK: - Properties
    var menuDataSource: [String]? {
        didSet { bind() }
    }
    
    lazy var horizontalScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    
    override func configureUI() {
        horizontalScrollView.addSubview(stackView)
        addSubview(horizontalScrollView)
    }
    
    override func setLayout() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        horizontalScrollView.snp.makeConstraints { make in
            make.center.width.equalToSuperview()
            make.height.equalTo(stackView)
            make.trailing.equalToSuperview()
        }
    }
    
    private func bind() {
        menuDataSource?.forEach { menuData in
            let button = createButton(menuData)
            stackView.addArrangedSubview(button)
            debugPrint(menuData)
        }
    }
    
    private func createButton(_ title: String) -> UIButton {
        var config = UIButton.Configuration.borderedTinted()
        config = configureButton(config, title)
        return UIButton(configuration: config)
    }
    
    private func configureButton(_ config: UIButton.Configuration, _ title: String) -> UIButton.Configuration {
        var config = config
        
        let attributedString = AttributedString(
            title,
            attributes: AttributeContainer([
                .font: EATSSUDesignFontFamily.Pretendard.medium.font(size: 10),
                .foregroundColor: EATSSUDesignAsset.Color.Main.primary.color]))
        config.attributedTitle = attributedString
        config.baseBackgroundColor = EATSSUDesignAsset.Color.Main.secondary.color
        config.background.strokeColor = EATSSUDesignAsset.Color.Main.primary.color
        config.background.strokeWidth = 0.5
        
        config.image = EATSSUDesignAsset.Images.thumbUp.image
        config.imagePadding = 1
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 6, bottom: 5, trailing: 6)
        
        return config
    }
}
