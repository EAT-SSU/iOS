//
//  ReviewRateResponse.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/07/29.
//

import Foundation

struct ReviewRateResponse: Codable {
    let menuNames: [String]
    let totalReviewCount: Int
    let mainRating: Double?
    let amountRating: Double?
    let tasteRating: Double?
    let reviewRatingCount: StarCount
}

struct StarCount: Codable {
    let fiveStarCount: Int
    let fourStarCount: Int
    let threeStarCount: Int
    let twoStarCount: Int
    let oneStarCount: Int
}
