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
    let numberOfElements: Int
    let hasNext: Bool
    let dataList: [MyReviewListItem]
}

// MARK: - Review Item DTO

/// 개별 리뷰 아이템 구조
struct MyReviewListItem: Codable {
    let reviewId: Int
    let rating: Double?
    let writtenAt: String
    let content: String?
    let imageUrls: [String]?
    let menuList: [ReviewMenu]
}

/// 리뷰에 포함된 개별 메뉴 구조
struct ReviewMenu: Codable {
    let id: Int
    let name: String
    let isLike: Bool   
}
