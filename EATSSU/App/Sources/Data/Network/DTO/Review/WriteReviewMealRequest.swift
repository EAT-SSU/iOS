//
//  WriteReviewMealRequest.swift
//  EATSSU
//
//  Created by 한금준 on 11/16/25.
//

// 리뷰v2 api
struct WriteReviewMealRequest: Encodable {
    let mealId: Int
    let rating: Int
    let menuLikes: [MenuLike]
    let content: String?
    let imageUrls: [String]?
}

struct MenuLike: Encodable {
    let menuId: Int
    let isLike: Bool
    
    private enum CodingKeys: String, CodingKey {
        case menuId
        case isLike
    }
}
