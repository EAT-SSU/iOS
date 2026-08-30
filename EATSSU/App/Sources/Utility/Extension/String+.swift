//
//  String+.swift
//  EATSSU
//
//  Created by jeongminji on 5/4/26.
//

import Foundation

import UIKit

extension String {
    /// 문자열 중 `highlight` 부분만 강조 색으로 칠한 AttributedString 반환.
    /// `highlight`가 포함되어 있지 않으면 전체가 baseColor
    func highlighted(
        _ highlight: String,
        baseColor: UIColor,
        highlightColor: UIColor
    ) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(
            string: self,
            attributes: [.foregroundColor: baseColor]
        )

        let range = (self as NSString).range(of: highlight)
        guard range.location != NSNotFound else { return attributedString }

        attributedString.addAttribute(.foregroundColor, value: highlightColor, range: range)
        return attributedString
    }
}
