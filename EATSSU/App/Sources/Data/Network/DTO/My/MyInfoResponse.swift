//
//  MyInfoResponse.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/08/14.
//

import Foundation

struct MyInfoResponse: Codable {
    let nickname: String?
    let provider: String
    let departmentId: Int?
    let departmentName: String?
    let collegeId: Int?
    let collegeName: String?
}
