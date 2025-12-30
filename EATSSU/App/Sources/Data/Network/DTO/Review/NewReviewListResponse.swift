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
    var menu: [ReviewMenuInfo]?  // 항상 배열로 저장
    let writerId: Int?
    let isWriter: Bool
    let writerNickname: String
    let rating: Double
    let writtenAt: String
    let content: String?
    /// 유효한 이미지 URL 문자열만 담는 배열 (null / 빈 문자열은 필터링)
    let imageUrls: [String]

    enum CodingKeys: String, CodingKey {
        case reviewId
        case menu
        case menuList
        case writerId
        case isWriter
        case writerNickname
        case rating
        case writtenAt
        case content
        case imageUrls
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        reviewId = try container.decode(Int.self, forKey: .reviewId)
        writerId = try container.decodeIfPresent(Int.self, forKey: .writerId)
        isWriter = try container.decode(Bool.self, forKey: .isWriter)
        writerNickname = try container.decode(String.self, forKey: .writerNickname)
        rating = try container.decode(Double.self, forKey: .rating)
        writtenAt = try container.decode(String.self, forKey: .writtenAt)
        content = try container.decodeIfPresent(String.self, forKey: .content)

        // menu 처리: Fixed 메뉴(객체)와 Variable 메뉴(배열) 모두 처리
        if let menuArray = try? container.decodeIfPresent([ReviewMenuInfo].self, forKey: .menuList) {
            // Variable 메뉴: menuList가 배열로 들어오는 경우
            menu = menuArray
        } else if let singleMenu = try? container.decodeIfPresent(ReviewMenuInfo.self, forKey: .menu) {
            // Fixed 메뉴: menu가 단일 객체로 들어오는 경우 -> 배열로 변환
            menu = [singleMenu]
        } else {
            menu = nil
        }

        // imageUrls: [String?] 형태로 받아서 nil / 빈 문자열을 제거해 [String]으로 정제
        let rawImageUrls = try container.decodeIfPresent([String?].self, forKey: .imageUrls) ?? []
        imageUrls = rawImageUrls.compactMap { url in
            guard let url, url.isEmpty == false else { return nil }
            return url
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(reviewId, forKey: .reviewId)
        try container.encodeIfPresent(menu, forKey: .menuList)
        try container.encodeIfPresent(writerId, forKey: .writerId)
        try container.encode(isWriter, forKey: .isWriter)
        try container.encode(writerNickname, forKey: .writerNickname)
        try container.encode(rating, forKey: .rating)
        try container.encode(writtenAt, forKey: .writtenAt)
        try container.encodeIfPresent(content, forKey: .content)
        try container.encode(imageUrls, forKey: .imageUrls)
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
