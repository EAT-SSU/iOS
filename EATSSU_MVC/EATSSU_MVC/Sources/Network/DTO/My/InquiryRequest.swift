//
//  InquiryRequest.swift
//  EAT-SSU
//
//  Created by 박윤빈 on 3/16/24.
//

import Foundation

struct InquiryRequest: Codable {
    let email: String
    let content: String

    init(_ email: String, _ content: String) {
        self.email = email
        self.content = content
    }
}
