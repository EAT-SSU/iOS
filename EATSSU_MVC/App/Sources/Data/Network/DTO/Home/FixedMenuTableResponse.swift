//
//  FixedMenuTableResponse.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/05/27.
//

import Foundation

struct FixedMenuTableResponse: Codable {
    let categoryMenuListCollection: [CategoryMenuListCollection]
}

struct CategoryMenuListCollection: Codable {
    let category: String
    let menus: [Menus]
}

struct Menus: Codable {
    let menuId: Int
    let name: String
    let price: Int?
    let rating: Double?
}
