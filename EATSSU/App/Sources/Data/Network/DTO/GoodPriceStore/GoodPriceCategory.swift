//
//  GoodPriceCategory.swift
//  EATSSU
//
//  Created by 황상환 on 8/23/26.
//

import Foundation

/// 착한가격업소 업종 필터. 순서 = 화면 필터 노출 순서
enum GoodPriceCategory: CaseIterable {
    case all
    case korean
    case japanese
    case western
    case chinese
    case bakery
    case etc

    /// 서버 category 파라미터 값. 전체는 nil
    var serverValue: String? {
        switch self {
        case .all:      return nil
        case .korean:   return "KOREAN"
        case .japanese: return "JAPANESE"
        case .western:  return "WESTERN"
        case .chinese:  return "CHINESE"
        case .bakery:   return "BAKERY"
        case .etc:      return "ETC"
        }
    }

    var title: String {
        switch self {
        case .all:      return TextLiteral.Map.all
        case .korean:   return TextLiteral.Map.korean
        case .japanese: return TextLiteral.Map.japanese
        case .western:  return TextLiteral.Map.western
        case .chinese:  return TextLiteral.Map.chinese
        case .bakery:   return TextLiteral.Map.bakery
        case .etc:      return TextLiteral.Map.etc
        }
    }

    /// 서버 category 문자열 → enum (전체는 매칭 대상 아님)
    init?(serverValue: String) {
        guard let matched = Self.allCases.first(where: { $0.serverValue == serverValue }) else {
            return nil
        }
        self = matched
    }
}
