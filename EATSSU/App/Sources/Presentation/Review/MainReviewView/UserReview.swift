//
//  UserReview.swift
//  EATSSU-DEV
//
//  Created by 최지우 on 2/1/25.
//

import Foundation

struct UserReview {
    let numberOfElements: Int
    let hasNext: Bool
    let dataList: [ReviewDataList]
}

struct ReviewDataList: Codable {
    let reviewId, writerId: Int
    let isWriter: Bool
    let writerNickname: String
    let rating: Int
    let writtenAt, content: String
    let imageUrls: [String]
//    let menuChipList: [String]
}

let sampleUserReviewData: [ReviewDataList] =
    [ReviewDataList(reviewId: 1, writerId: 1, isWriter: false, writerNickname: "숭실숭실", rating: 4, writtenAt: "2023.03.03", content: "고치도니", imageUrls: []),ReviewDataList(reviewId: 2, writerId: 2, isWriter: false, writerNickname: "jiwoo", rating: 2, writtenAt: "2024.1.2", content: "여기 고치돈 맛집임... 치즈가 좌아악 늘어나고 맛있음 고구마무스도 완전 많아!!!!", imageUrls: [])]
