//
//  PartnershipResponse.swift
//  EATSSUNetwork
//
//  Created by JIWOONG CHOI on 2/17/25.
//

import Foundation

public struct PartnershipResponse: Codable {
    public let id: Int
    public let partnershipType, storeName, description, startDate: String
    public let endDate, restaurantType: String
    public let longitude, latitude: Double
    public let collegeNames, departmentNames: [String]
}
