//
//  ReviewListResponse.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/08/01.
//

import Foundation

struct ReviewListResponse: Codable {
    let numberOfElements: Int
    let hasNext: Bool
    let dataList: [MenuDataList]
}

// MARK: - DataList

struct MenuDataList: Codable {
    let reviewID: Int
    let menu: String
    let writerID: Int?
    let isWriter: Bool
    let writerNickname: String
    let mainRating, amountRating, tasteRating: Int
    let writedAt, content: String
    let imgURLList: [String]

    enum CodingKeys: String, CodingKey {
        case reviewID = "reviewId"
        case menu
        case writerID = "writerId"
        case isWriter, writerNickname, mainRating, amountRating, tasteRating, writedAt, content
        case imgURLList = "imageUrls"
    }
}
