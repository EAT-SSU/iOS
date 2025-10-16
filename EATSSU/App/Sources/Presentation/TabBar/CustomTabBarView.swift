//
//  CustomTabBarView.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 6/21/25.
//

import UIKit

import EATSSUDesign

final class CustomTabBarView: BaseUIView {

    // MARK: - Constants
    
    private static let titles = ["학식", "지도", "마이"]
    private static let normalImages = [
        EATSSUDesignAsset.Images.tabMeal.image,
        EATSSUDesignAsset.Images.tabMap.image,
        EATSSUDesignAsset.Images.tabMypage.image
    ]
    private static let selectedImages = [
        EATSSUDesignAsset.Images.tabMealSelected.image,
        EATSSUDesignAsset.Images.tabMapSelected.image,
        EATSSUDesignAsset.Images.tabMypageSelected.image
    ]
    private static let imageSizes = [
        CGSize(width: 23, height: 23),
        CGSize(width: 23, height: 23),
        CGSize(width: 44, height: 23)
    ]

    // MARK: - Properties

    var buttonTapped: ((Int) -> Void)?

    private let buttons: [UIButton] = {
        return Self.titles.indices.map { index in
            let title = Self.titles[index]
            let normalImage = Self.normalImages[index]
            let imageSize = Self.imageSizes[index]
            
            let resizedImage = normalImage.resized(to: imageSize)
            
            var config = UIButton.Configuration.plain()
            config.title = title
            config.image = resizedImage
            config.imagePlacement = .top
            config.imagePadding = 4
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)

            let button = UIButton(configuration: config, primaryAction: nil)
            button.tag = index

            let font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 12)
            var attrTitle = AttributedString(title)
            attrTitle.font = font
            attrTitle.foregroundColor = .gray500
            config.attributedTitle = attrTitle
            button.configuration = config

            return button
        }
    }()

    // MARK: - View Setup

    override func configureUI() {
        // 배경 및 그림자 설정
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.masksToBounds = false

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowOffset = CGSize(width: 0, height: -3)
        layer.shadowRadius = 12

        // 각 버튼 액션 연결
        buttons.forEach { button in
            button.setTitleColor(.gray500, for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
    }

    override func setLayout() {
        // 버튼을 수평 스택뷰로 배치
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        addSubview(stack)

        stack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }
    }

    // MARK: - Public Functions

    /// 선택된 인덱스의 버튼 스타일 업데이트
    func setSelectedIndex(_ index: Int) {
        for (i, button) in buttons.enumerated() {
            let isSelected = i == index
            let color: UIColor = isSelected ? EATSSUDesignAsset.Color.Main.primary.color : .gray500
            
            let image = isSelected ? Self.selectedImages[i] : Self.normalImages[i]
            let resizedImage = image.resized(to: Self.imageSizes[i])

            if var config = button.configuration,
               let title = config.title {
                var attrTitle = AttributedString(title)
                attrTitle.font = isSelected ? EATSSUDesignFontFamily.Pretendard.bold.font(size: 11) : EATSSUDesignFontFamily.Pretendard.regular.font(size: 11)
                attrTitle.foregroundColor = color
                config.attributedTitle = attrTitle
                config.image = resizedImage
                button.configuration = config
            }
        }
    }

    // MARK: - Actions

    /// 버튼 클릭 시 인덱스 변경 및 콜백 호출
    @objc private func buttonTapped(_ sender: UIButton) {
        setSelectedIndex(sender.tag)
        buttonTapped?(sender.tag)
    }
}

// MARK: - UIImage Extension

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
