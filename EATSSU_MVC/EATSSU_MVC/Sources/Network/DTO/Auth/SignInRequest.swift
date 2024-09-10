//
//  SignInRequest.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/05/27.
//

import Foundation

struct SignInRequest: Codable {
    let email: String
    let pwd: String
    
    init(_ email: String, _ pwd: String) {
        self.email = email
        self.pwd = pwd
    }
}
