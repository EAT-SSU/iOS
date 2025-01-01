//
//  BaseResponse.swift
//  EAT-SSU
//
//  Created by 박윤빈 on 2/12/24.
//

import Foundation

struct BaseResponse<T: Codable>: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: T
}
