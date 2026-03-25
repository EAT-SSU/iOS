//
//  PublicHolidayResponseDTO.swift
//  EATSSU
//
//  Created by jeongminji on 3/25/26.
//

import Foundation

struct PublicHolidayResponseDTO: Decodable {
    let response: PublicHolidayEnvelopeDTO
}

struct PublicHolidayEnvelopeDTO: Decodable {
    let header: PublicHolidayHeaderDTO
    let body: PublicHolidayBodyDTO
}

struct PublicHolidayHeaderDTO: Decodable {
    let resultCode: String
}

struct PublicHolidayBodyDTO: Decodable {
    let items: PublicHolidayItemsDTO?
}

struct PublicHolidayItemsDTO: Decodable {
    let item: PublicHolidayItemContainerDTO
}

struct PublicHolidayItemDTO: Decodable {
    let dateName: String?
    let isHoliday: String?
    let locdate: Int
}

enum PublicHolidayItemContainerDTO: Decodable {
    case one(PublicHolidayItemDTO)
    case many([PublicHolidayItemDTO])
    
    var values: [PublicHolidayItemDTO] {
        switch self {
        case let .one(item):
            return [item]
        case let .many(items):
            return items
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let items = try? container.decode([PublicHolidayItemDTO].self) {
            self = .many(items)
        } else {
            self = .one(try container.decode(PublicHolidayItemDTO.self))
        }
    }
}
