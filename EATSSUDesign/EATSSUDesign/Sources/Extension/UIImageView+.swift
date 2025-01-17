//
//  UIImageView+.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/08/01.
//

import Kingfisher
import UIKit

extension UIImageView {
    func kfSetImage(url: String?) {
        guard let url = url else { return }

        if let url = URL(string: url) {
            kf.indicatorType = .activity
            kf.setImage(with: url,
                        placeholder: nil,
                        options: [.transition(.fade(1.0))], progressBlock: nil)
        }
    }
}
