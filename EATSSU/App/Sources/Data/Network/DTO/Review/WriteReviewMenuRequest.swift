//
//  WriteReviewMenuRequest.swift
//  EATSSU
//
//  Created by 한금준 on 11/16/25.
//

// 리뷰v2 api
struct WriteReviewMenuRequest: Encodable {
    let rating: Int
    let menuLike: MenuLike
    let content: String?
    let imageUrls: [String]?
}
