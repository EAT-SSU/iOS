//
//  UserNicknameRequest.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/08/01.
//

import Foundation

struct UserNicknameRequest: Codable {
    let nickname: String
    
    init(_ nickname: String) {
        self.nickname = nickname
    }
}
