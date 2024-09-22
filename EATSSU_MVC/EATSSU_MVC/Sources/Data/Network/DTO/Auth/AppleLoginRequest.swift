//
//  AppleLoginRequest.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/08/10.
//

import Foundation

struct AppleLoginRequest: Codable {
    let identityToken: String
    
    init(identityToken: String) {
        self.identityToken = identityToken
    }
}
