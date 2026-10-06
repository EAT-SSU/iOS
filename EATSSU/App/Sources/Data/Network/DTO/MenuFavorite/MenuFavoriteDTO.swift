//
//  MenuFavoriteDTO.swift
//  EATSSU
//
//  Created by 황상환 on 10/6/26.
//

import Foundation

/// 찜한 메뉴 (`GET /menu-favorites`, 최근 찜한 순)
struct FavoriteMenuDTO: Codable, Equatable {
    let menuId: Int
    /// 서버에 저장된 유저 언어 기준. 번역이 없으면 한국어
    let menuName: String
    /// 식당 코드 (`DODAM`, `DORMITORY`, `HAKSIK`, `FACULTY`, `SNACK_CORNER`, `FOOD_COURT`)
    let restaurant: String
    let isDiscontinued: Bool
}

/// 찜할 메뉴 검색 결과 (`GET /menu-favorites/search`). 같은 메뉴명이라도 식당이 다르면 따로 내려온다
struct MenuSearchDTO: Codable, Equatable {
    let menuId: Int
    let menuName: String
    let restaurant: String
    let isFavorite: Bool
}
