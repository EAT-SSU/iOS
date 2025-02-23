//
//  BaseResponseWithoutResult.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 2/23/25.
//

import Foundation

struct BaseResponseWithoutResult: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
}
