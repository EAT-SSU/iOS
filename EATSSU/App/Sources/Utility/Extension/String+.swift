//
//  String+.swift
//  EATSSU
//
//  Created by jeongminji on 5/4/26.
//

import Foundation

import UIKit

extension String {
    /// 문자열에서 마지막 단어만 지정한 색상으로 강조한 attributed string을 반환
    /// - Parameters:
    ///   - baseColor: 전체 문자열에 기본으로 적용할 색상
    ///   - highlightColor: 마지막 단어에 적용할 강조 색상
    /// - Returns: 마지막 단어만 강조 색상이 적용된 `NSAttributedString`
    func logoHighlightedLastWord(
        baseColor: UIColor,
        highlightColor: UIColor
    ) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(
            string: self,
            attributes: [
                .foregroundColor: baseColor
            ]
        )

        guard let lastWord = self.split(separator: " ").last else {
            return attributedString
        }

        let nsString = self as NSString
        let range = nsString.range(of: String(lastWord), options: .backwards)

        attributedString.addAttribute(
            .foregroundColor,
            value: highlightColor,
            range: range
        )

        return attributedString
    }
}
