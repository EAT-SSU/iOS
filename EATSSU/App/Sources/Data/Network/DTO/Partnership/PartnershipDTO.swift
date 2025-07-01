//
//  PartnershipDTO.swift
//  EATSSU
//
//  Created by 황상환 on 7/1/25.
//

import Foundation

struct PartnershipDTO: Codable {
    let id: Int
    let partnershipType: String
    let storeName: String
    let description: String
    let startDate: String
    let endDate: String
    let restaurantType: String
    let longitude: Double
    let latitude: Double
    let collegeNames: [String]
    let departmentNames: [String]
}
