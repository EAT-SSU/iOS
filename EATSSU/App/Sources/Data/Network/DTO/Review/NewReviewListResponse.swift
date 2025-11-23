//
//  NewReviewListResponse.swift
//  EATSSU
//
//  Created by 한금준 on 11/16/25.
//

struct NewReviewListResponse: Codable {
    let hasNext: Bool
    let dataList: [ReviewListItem]
}

/// 리뷰 리스트 조회 API의 result 내부 DTO (Menu용 - 페이지 기반)
struct NewMenuListResponse: Codable {
    let numberOfElements: Int?
    let hasNext: Bool
    let dataList: [ReviewListItem]
}

struct ReviewListItem: Codable {
    let reviewId: Int
    let menuList: [ReviewMenuInfo]?
    let writerId: Int
    let isWriter: Bool
    let writerNickname: String
//    let rating: Int
    let rating: Double
    let writtenAt: String
    let content: String?
    let imageUrls: [String]?
}

struct ReviewMenuInfo: Codable {
    let menuId: Int
    let name: String
    let isLike: Bool
}

struct Tag: Codable {
    let name: String
    let isLiked: Bool
}
