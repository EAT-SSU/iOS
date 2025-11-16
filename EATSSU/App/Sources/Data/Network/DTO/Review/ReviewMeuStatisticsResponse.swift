//
//  ReviewMeuStatistics.swift
//  EATSSU
//
//  Created by 한금준 on 11/16/25.
//

struct ReviewMeuStatisticsResponse: Encodable {
    let menuName: String
    let totalReviewCount: Int
    let rating: Double
    let likeCount: Int?
    let dislikeCount: Int?
    let reviewRatingCount: ReviewRatingCount
}

struct ReviewRatingCount: Encodable {
    let oneStarCount: Int
    let twoStarCount: Int
    let threeStarCount: Int
    let fourStarCount: Int
    let fiveStarCount: Int
}
