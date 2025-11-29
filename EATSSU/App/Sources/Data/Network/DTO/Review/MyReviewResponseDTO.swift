//
//  MyReviewResponseDTO.swift
//  EATSSU
//
//  Created by 한금준 on 11/29/25.
//

import Foundation

// MARK: - API Response DTO

/// 내가 쓴 리뷰 리스트 전체 응답 구조
struct MyReviewResponseDTO: Codable {
    let result: MyReviewList
}

/// 리뷰 리스트 데이터 컨테이너
struct MyReviewList: Codable {
    let numberOfElements: Int   // 총 요소 개수
    let hasNext: Bool           // 다음 페이지 존재 여부
    let dataList: [MyReviewListItem] // 리뷰 목록
}

// MARK: - Review Item DTO

/// 개별 리뷰 아이템 구조
struct MyReviewListItem: Codable {
    let reviewId: Int       // 리뷰 ID
    let rating: Double      // 별점 (4)
    let writtenAt: String   // 작성일 ("2023-04-07")
    let content: String?    // 리뷰 내용 ("맛있당")
    let imageUrls: [String]? // 이미지 URL 리스트 ("imgurl1", "imgurl2")
    let menuList: [ReviewMenu] // 리뷰에 포함된 메뉴 리스트
}

/// 리뷰에 포함된 개별 메뉴 구조
struct ReviewMenu: Codable {
    let menuId: Int     // 메뉴 ID (3143)
    let name: String    // 메뉴 이름 ("생고기제육볶음")
    let isLike: Bool    // 좋아요 여부 (true)
}
