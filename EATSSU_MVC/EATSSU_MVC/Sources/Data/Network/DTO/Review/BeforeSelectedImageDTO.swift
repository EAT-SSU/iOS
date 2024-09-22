//
//  BeforeSelectedImageDTO.swift
//  EAT-SSU
//
//  Created by 박윤빈 on 3/7/24.
//

import Foundation

struct BeforeSelectedImageDTO: Codable {
    let mainRating: Int
    let amountRating: Int
    let tasteRating: Int
    let content: String

    init(mainRating: Int, amountRating: Int, tasteRating: Int, content: String) {
        self.mainRating = mainRating
        self.amountRating = amountRating
        self.tasteRating = tasteRating
        self.content = content
    }
}
