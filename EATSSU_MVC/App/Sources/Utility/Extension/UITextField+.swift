//
//  UITextField+.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/04/06.
//

import UIKit

extension UITextField {
    /// 글자 시작위치 변경 메소드
    func addLeftPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: -14, height: -10))
        leftView = paddingView
        leftViewMode = ViewMode.always
    }

    func addLeftPadding(width: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: frame.height))
        leftView = paddingView
        leftViewMode = .always
    }

    func addRightPadding(width: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: frame.height))
        rightView = paddingView
    }

    /// 좌측 이미지 추가
    func addLeftImage(image: UIImage) {
        let leftImage = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        leftImage.image = image
        leftView = leftImage
        leftViewMode = .always
    }

    /// EATTSSU Textfield의 Border 설정
    func setRoundBorder() {
        layer.masksToBounds = true
        layer.borderColor = EATSSUAsset.Color.GrayScale.gray200.color.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 10
    }
}
