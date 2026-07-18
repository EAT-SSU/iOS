//
//  ReviewTranslationResponse.swift
//  EATSSU
//
//  Created by 황상환 on 7/18/26.
//

/// 리뷰 번역 API 응답
struct ReviewTranslationResponse: Codable {
    let reviewId: Int
    let language: String
    let translatedContent: String
    /// 서버 캐시 히트 여부
    let cached: Bool
}
