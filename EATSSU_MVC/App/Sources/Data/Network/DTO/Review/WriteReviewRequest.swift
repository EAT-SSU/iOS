//
//  WriteReviewRequest.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/05/24.
//

import UIKit

struct WriteReviewRequest: Codable {
    let mainRating: Int
    let amountRating: Int
    let tasteRating: Int
    let content: String
    let imageUrl: String

    init(mainRating: Int, amountRating: Int, tasteRating: Int, content: String, imageURL: String?) {
        self.mainRating = mainRating
        self.amountRating = amountRating
        self.tasteRating = tasteRating
        self.content = content
        imageUrl = imageURL ?? ""
    }

    init(content: BeforeSelectedImageDTO, imageURL: String?) {
        mainRating = content.mainRating
        amountRating = content.amountRating
        tasteRating = content.tasteRating
        self.content = content.content
        imageUrl = imageURL ?? ""
    }
}
