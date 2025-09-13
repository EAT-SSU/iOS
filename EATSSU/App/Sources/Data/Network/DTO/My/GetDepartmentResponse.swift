//
//  GetDepartmentResponse.swift
//  EATSSU
//
//  Created by 황상환 on 7/7/25.
//

import Foundation

struct GetDepartmentResponse: Codable {
    let departmentId: Int
    let departmentName: String
    let collegeId: Int
    let collegeName: String
}
