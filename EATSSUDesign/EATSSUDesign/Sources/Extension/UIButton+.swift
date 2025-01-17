//
//  UIButton+.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/06/27.
//

import UIKit

extension UIButton {
    /// Button 상태에 따른 Color 지정
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        let minimumSize = CGSize(width: 1.0, height: 1.0)

        UIGraphicsBeginImageContext(minimumSize)

        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(origin: .zero, size: minimumSize))
        }

        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        clipsToBounds = true
        setBackgroundImage(colorImage, for: state)
    }

    /// Button 타이틀 속성 지정
    func addTitleAttribute(title: String, titleColor: UIColor, fontName: UIFont) {
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        titleLabel?.font = fontName
    }

    /// Button border 속성 지정
    func setRoundBorder(borderColor: UIColor, borderWidth: CGFloat, cornerRadius: CGFloat) {
        layer.masksToBounds = true
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
    }

    /// title / image vertical align
    func alignTextBelow(spacing _: CGFloat = 8.0) {
        guard let image = imageView?.image else {
            return
        }

        guard let titleLabel = titleLabel else {
            return
        }

        guard let titleText = titleLabel.text else {
            return
        }

        let titleSize = titleText.size(withAttributes: [
            NSAttributedString.Key.font: titleLabel.font as Any,
        ])
    }
}
