//
//  FixedReviewRequestDTO.swift
//  EATSSU
//
//  Created by 한금준 on 11/24/25.
//

import Foundation

struct FixedReviewRequestDTO: Encodable {
    let rating: Int
    let menuLikes: [MenuLike]
    let content: String
}
