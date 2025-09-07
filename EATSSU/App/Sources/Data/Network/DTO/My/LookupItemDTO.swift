//
//  LookupItemDTO.swift
//  EATSSU
//
//  Created by 황상환 on 8/13/25.
//

import Foundation

struct LookupItemDTO: Codable {
    let id: Int
    let name: String
}

typealias CollegesResponseDTO = BaseResponse<[LookupItemDTO]>
typealias DepartmentsResponseDTO = BaseResponse<[LookupItemDTO]>
