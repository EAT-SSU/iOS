//
//  ReviewTranslationResponse.swift
//  EATSSU
//
//  Created by 황상환 on 7/18/26.
//

/// 리뷰 번역 API 응답
///
/// 실제 사용하는 값은 translatedContent뿐이라, 나머지는 서버가 생략해도 디코딩이 깨지지 않도록 옵셔널로 둔다.
struct ReviewTranslationResponse: Codable {
    let reviewId: Int?
    let language: String?
    let translatedContent: String
    /// 서버 캐시 히트 여부
    let cached: Bool?
}
