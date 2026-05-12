//
//  PartnershipDTO.swift
//  EATSSU
//
//  Created by 황상환 on 7/1/25.
//

import Foundation

struct PartnershipDTO: Codable {
    let storeName: String
    let longitude: Double
    let latitude: Double
    let restaurantType: String
    let partnershipInfos: [PartnershipInfoDTO]
}

struct PartnershipInfoDTO: Codable {
    let id: Int
    let collegeName: String?
    let departmentName: String?
    let likeCount: Int
    let isLiked: Bool
    let description: String
    let startDate: String
    let endDate: String
    let periodType: PartnershipPeriodType
}

enum PartnershipPeriodType: String, Codable {
    case normal = "NORMAL"
    case festival = "FESTIVAL"
}
