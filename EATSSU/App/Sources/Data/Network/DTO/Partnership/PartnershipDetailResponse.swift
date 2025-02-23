//
//  PartnershipDetailResponse.swift
//  EATSSUNetwork
//
//  Created by JIWOONG CHOI on 2/17/25.
//

import Foundation

struct PartnershipDetailResponse: Codable {
    let id: Int
    let partnershipType, storeName, description, startDate: String
    let endDate, restaurantType: String
    let longitude, latitude: Double
    let collegeNames, departmentNames: [String]
    let partnershipLikeCount: Int
    let likedByUser: Bool
}
