//
//  UIView+.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/03/15.
//

import Foundation
import UIKit

extension UIView {
    public func addSubviews(_ views: UIView...) {
        views.forEach { self.addSubview($0) }
    }

    public func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
