//
//  ReviewMenuStatistics.swift
//  EATSSU
//
//  Created by 한금준 on 11/16/25.
//

// 리뷰V2 api
struct ReviewMenuStatisticsResponse: Codable {
    let menuName: String
    let totalReviewCount: Int
    let rating: Double?
    let likeCount: Int?
    let reviewRatingCount: ReviewRatingCount
}

struct ReviewRatingCount: Codable {
    let oneStarCount: Int
    let twoStarCount: Int
    let threeStarCount: Int
    let fourStarCount: Int
    let fiveStarCount: Int
}
