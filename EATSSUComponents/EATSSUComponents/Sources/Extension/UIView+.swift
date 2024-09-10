//
//  UIView+.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/03/15.
//

import Foundation
import UIKit

extension UIView {
    
    func addSubviews(_ views: UIView...) {
        views.forEach { self.addSubview($0) }
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
         let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
         let mask = CAShapeLayer()
         mask.path = path.cgPath
         layer.mask = mask
     }
}

extension UIView {
    func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        let toastWidth = toastLabel.intrinsicContentSize.width + 20
        let toastHeight = toastLabel.intrinsicContentSize.height + 10
        toastLabel.frame = CGRect(x: self.frame.size.width/2 - toastWidth/2,
                                   y: self.frame.size.height - toastHeight - 30,
                                   width: toastWidth,
                                   height: toastHeight)
        self.addSubview(toastLabel)
        
        UIView.animate(withDuration: 1.6, delay: 0.6, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
