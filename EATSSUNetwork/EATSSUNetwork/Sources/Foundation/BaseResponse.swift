//
//  BaseResponse.swift
//  EAT-SSU
//
//  Created by 박윤빈 on 2/12/24.
//

import Foundation

public struct BaseResponse<T: Codable>: Codable {
    public let isSuccess: Bool
    public let code: Int
    public let message: String
    public let result: T
}
