//
//  Int+.swift
//  EATSSU
//
//  Created by 최지우 on 9/18/24.
//

import Foundation

extension Int {
    var formattedWithCommas: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
