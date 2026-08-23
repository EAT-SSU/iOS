//
//  GoodPriceStoreDTO.swift
//  EATSSU
//
//  Created by 황상환 on 8/23/26.
//

import Foundation

/// 착한가격업소 목록 항목 (GET /good-price-stores)
struct GoodPriceStoreDTO: Codable {
    let id: Int
    let storeName: String
    let category: String
    let latitude: Double
    let longitude: Double
}

/// 착한가격업소 상세 (GET /good-price-stores/{id})
struct GoodPriceStoreDetailDTO: Codable {
    let id: Int
    let storeName: String
    let category: String
    let mainMenu: String?
    let price: Int?
    let roadAddress: String?
    let imageUrl: String?
}
