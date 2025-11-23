//
//  ReviewValidMenuResponse.swift
//  EATSSU
//
//  Created by 한금준 on 11/16/25.
//

// 리뷰V2 식단 id를 통해 리뷰 작성할 수 있는 메뉴들 조회
struct ReviewValidMenusResponse: Codable {
    let menuList: [ReviewValidMenu]
}

struct ReviewValidMenu: Codable {
    let menuId: Int
    let name: String
}
