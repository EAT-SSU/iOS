//
//  Int+.swift
//  EATSSU
//
//  Created by 최지우 on 9/18/24.
//

import Foundation

extension Int {
    
    /// Int 타입 숫자에서 commas(,)를 추가한 String타입을 반환하는 computed property 입니다.
    var formattedWithCommas: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
