//
//  NewReviewListResponse.swift
//  EATSSU
//
//  Created by 한금준 on 11/16/25.
//

/// 리뷰 V2 리스트 조회 API
struct NewReviewListResponse: Codable {
    let numberOfElements: Int?
    let hasNext: Bool
    let dataList: [ReviewListItem]
}

struct ReviewListItem: Codable {
    let reviewId: Int
    var menu: [ReviewMenuInfo]?
    let writerId: Int?
    let isWriter: Bool
    let writerNickname: String
    let rating: Double
    let writtenAt: String
    let content: String?
    let imageUrls: [String]?

    enum CodingKeys: String, CodingKey {
        case reviewId
        case menu = "menuList"
        case writerId
        case isWriter
        case writerNickname
        case rating
        case writtenAt
        case content
        case imageUrls
    }
}

struct ReviewMenuInfo: Codable {
    let menuId: Int
    let name: String
    let isLike: Bool

    enum CodingKeys: String, CodingKey {
        case menuId = "id"
        case name
        case isLike
    }
}

struct Tag: Codable {
    let name: String
    let isLiked: Bool
}
