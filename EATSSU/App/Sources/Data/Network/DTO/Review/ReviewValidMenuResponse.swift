//
//  ReviewValidMenuResponse.swift
//  EATSSU
//
//  Created by 한금준 on 11/16/25.
//

struct ReviewValidMenusResponse: Codable {
    let menuList: [ReviewValidMenu] // 메뉴 목록 배열
}

struct ReviewValidMenu: Codable {
    let menuId: Int
    let name: String
}
