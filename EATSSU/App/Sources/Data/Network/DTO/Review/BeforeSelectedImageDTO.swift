//
//  BeforeSelectedImageDTO.swift
//  EAT-SSU
//
//  Created by 박윤빈 on 3/7/24.
//

import Foundation

struct BeforeSelectedImageDTO: Codable {
    let mainRating: Int
    let amountRating: Int?
    let tasteRating: Int?
    let content: String
}
