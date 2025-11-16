//
//  NewMealListResponse.swift
//  EATSSU
//
//  Created by 한금준 on 11/16/25.
//

struct ReviewMealResponse: Encodable {
    let reviewId: Int
    let writerId: Int
    let isWriter: Bool
    let writerNickname: String
    let rating: Int
    let writtenAt: String
    let content: String?
    let imageUrls: [String]?
    let menuList: [ReviewMealInfo]?
}

struct ReviewMealInfo: Encodable {
    let menuId: Int
    let name: String
    let isLike: Bool
}
