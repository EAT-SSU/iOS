//
//  ChangeMenuTableResponse.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/19.
//

import Foundation

struct ChangeMenuTableResponse: Codable {
    let mealId: Int?
    let price: Int?
    let mainRating: Double?
    var menusInformationList: [MenusInformation]
}

struct MenusInformation: Codable {
    let menuId: Int
    let name: String
}
