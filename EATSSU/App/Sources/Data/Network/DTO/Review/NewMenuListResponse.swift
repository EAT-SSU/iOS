//
//  NewReviewListResponse.swift
//  EATSSU
//
//  Created by 한금준 on 11/16/25.
//

/// 리뷰 리스트 조회 API의 result 내부 DTO (공통)
struct NewMenuListResponse: Encodable {
    let numberOfElements: Int? // menu API 응답 예시에 있음
    let hasNext: Bool
    let dataList: [ReviewListItem]
}

struct ReviewListItem: Encodable {
    let reviewId: Int
    let menuList: [ReviewMenuInfo]?
    let writerId: Int
    let isWriter: Bool // 리뷰 작성자인지 여부
    let writerNickname: String
    let rating: Int
    let writtenAt: String
    let content: String?
    let imageUrls: [String]?
}

struct ReviewMenuInfo: Encodable {
    let menuId: Int
    let name: String
    let isLike: Bool
}

