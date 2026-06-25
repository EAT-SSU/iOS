//
//  MyPageTableMetric.swift
//  EATSSU
//
//  Created by jeongminji on 5/3/26.
//

import Foundation

enum MyPageTableMetric {
    static let normalRowHeight: CGFloat = 48
    static let notificationRowHeight: CGFloat = 74
    static let headerHeight: CGFloat = 18
    static let footerHeight: CGFloat = 16

    static func rowHeight(for item: MyPageLabels) -> CGFloat {
        switch item {
        case .notificationSetting:
            return notificationRowHeight

        default:
            return normalRowHeight
        }
    }
}
