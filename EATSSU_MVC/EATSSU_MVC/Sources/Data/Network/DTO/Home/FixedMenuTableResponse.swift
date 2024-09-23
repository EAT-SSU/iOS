//
//  MenuTableResponse.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/05/27.
//

import Foundation

struct FixedMenuTableResponse: Codable {
    let categoryMenuListCollection: [CategoryMenu]
}

struct CategoryMenu: Codable {
    let category: String
    let menuInformationList: [MenuInformation]
}

struct MenuInformation: Codable {
    let menuId: Int
    let name: String
    let mainRating: Double?
    let price: Int?
}
