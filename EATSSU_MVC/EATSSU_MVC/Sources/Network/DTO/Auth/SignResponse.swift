//
//  SignUpResponse.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/05/27.
//

import Foundation

struct SignResponse: Codable {
    let accessToken: String
    let refreshToken: String
}
