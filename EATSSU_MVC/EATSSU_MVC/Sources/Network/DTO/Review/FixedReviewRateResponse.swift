//
//  FixedReviewRateResponse.swift
//  EAT-SSU
//
//  Created by 박윤빈 on 3/18/24.
//

import Foundation

// MARK: - FixedReviewRateResponse
struct FixedReviewRateResponse: Codable {
    let menuName: String
    let totalReviewCount: Int
    let mainRating, amountRating, tasteRating: Double?
    let reviewRatingCount: StarCount
}
