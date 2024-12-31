//
//  RestaurantInfoResponse.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/23.
//

import Foundation

struct RestaurantInfoResponse: Codable {
    let location: String
    let openHours: [OpenHourInfo]
}

struct OpenHourInfo: Codable {
    let dayType: String
    let timepart: String
    let time: String
}
