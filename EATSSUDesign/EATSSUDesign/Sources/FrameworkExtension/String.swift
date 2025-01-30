//
//  String.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/08/16.
//

import Foundation

extension String {
    func stringFromDate() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: now)
    }
}
