//
//  MenuReview.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/05/18.
//

import Foundation

struct MenuReviewResponse: Codable {
    let numberOfElements: Int
    let hasNext: Bool
    let dataList: [DataList]?
}

struct DataList: Codable {
    let writerId: Int
    let writerNickname: String
    let grade: Int
    let writeDate, content: String
    let tagList: [String]
    let imgUrlList: [String]
}
