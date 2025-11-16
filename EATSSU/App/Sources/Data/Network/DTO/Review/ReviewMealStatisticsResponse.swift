//
//  ReviewMealStatisticsResponse.swift
//  EATSSU
//
//  Created by 한금준 on 11/16/25.
//

struct ReviewMealStatisticsResponse: Encodable {
    // 식단에 포함된 메뉴 리스트
    let menuList: [MenuInfo] // Meal API 고유 필드
    
    let totalReviewCount: Int
    let rating: Double // 메인 평균 별점
    let likeCount: Int?
    let reviewRatingCount: ReviewRatingCount // 별점별 카운트
}

struct MenuInfo: Encodable {
    let id: Int
    let name: String
}

struct ReviewMealRatingCount: Encodable {
    let oneStarCount: Int
    let twoStarCount: Int
    let threeStarCount: Int
    let fourStarCount: Int
    let fiveStarCount: Int
}
