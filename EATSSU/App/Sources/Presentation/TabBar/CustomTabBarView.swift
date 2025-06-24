//
//  CustomTabBarView.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 6/21/25.
//

import UIKit

import EATSSUDesign

final class CustomTabBarView: BaseUIView {

    var buttonTapped: ((Int) -> Void)?

    private let buttons: [UIButton] = {
        let titles = ["학식", "지도", "마이"]
        let images = ["fork.knife", "map.fill", "person.fill"]

        return zip(titles, images).enumerated().map { index, pair in
            var config = UIButton.Configuration.plain()
            config.title = pair.0
            config.image = UIImage(
                systemName: pair.1,
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
            )
            config.imagePlacement = .top
            config.imagePadding = 4
            config.baseForegroundColor = .gray

            let button = UIButton(configuration: config, primaryAction: nil)
            button.tag = index

            let font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 12)
            var attrTitle = AttributedString(pair.0)
            attrTitle.font = font
            attrTitle.foregroundColor = .gray
            config.attributedTitle = attrTitle
            button.configuration = config

            return button
        }
    }()

    override func configureUI() {
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.masksToBounds = false

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowOffset = CGSize(width: 0, height: -3)
        layer.shadowRadius = 12

        buttons.forEach { button in
            button.setTitleColor(.gray, for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
    }

    override func setLayout() {
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        addSubview(stack)

        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(8) }
    }

    func setSelectedIndex(_ index: Int) {
        for (i, button) in buttons.enumerated() {
            let isSelected = i == index
            let color: UIColor = isSelected ? EATSSUDesignAsset.Color.Main.primary.color : .gray

            if var config = button.configuration,
               let title = config.title {
                var attrTitle = AttributedString(title)
                attrTitle.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 11)
                attrTitle.foregroundColor = color
                config.attributedTitle = attrTitle
                config.baseForegroundColor = color
                button.configuration = config
            }
        }
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        setSelectedIndex(sender.tag)
        buttonTapped?(sender.tag)
    }
}
