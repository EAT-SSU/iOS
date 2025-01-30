//
//  ESTabBar.swift
//  EATSSUDesign
//
//  Created by JIWOONG CHOI on 1/30/25.
//

import UIKit

public class ESTabBar: UITabBar {
    private var cornerRadius: CGFloat = 12.0 // 원하는 곡률 반경 값

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTabBar()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTabBar()
    }

    private func setupTabBar() {
        configureTransparency()
        configureCornerRadius()
        configureShadow()
    }

    private func configureTransparency() {
        backgroundImage = UIImage()
        shadowImage = UIImage()
    }

    private func configureCornerRadius() {
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // 상단 모서리만 둥글게
    }

    private func configureShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
        layer.masksToBounds = false
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        updateShadowPath()
    }

    private func updateShadowPath() {
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        ).cgPath
    }
}
