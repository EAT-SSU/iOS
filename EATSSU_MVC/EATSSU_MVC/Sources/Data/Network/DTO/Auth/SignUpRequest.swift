//
//  SignUpRequest.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/05/27.
//

import Foundation

struct SignUpRequest: Codable {
    let email: String
    let pwd: String
    let nickname: String
    
    init(_ email: String, _ pwd: String, _ nickname: String) {
        self.email = email
        self.pwd = pwd
        self.nickname = nickname
    }
}
