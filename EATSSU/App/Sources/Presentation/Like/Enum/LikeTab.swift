//
//  LikeTab.swift
//  EATSSU
//
//  Created by 황상환 on 8/30/26.
//

import Foundation

/// 찜 탭 상단 구분 (메뉴 찜 / 제휴 찜)
enum LikeTab: Int, CaseIterable {
    case menu
    case partnership

    var title: String {
        switch self {
        case .menu: TextLiteral.Like.menuTab
        case .partnership: TextLiteral.Like.partnershipTab
        }
    }
}
