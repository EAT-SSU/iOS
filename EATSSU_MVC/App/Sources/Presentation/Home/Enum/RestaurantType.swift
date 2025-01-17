//
//  RestaurantType.swift
//  EATSSU
//
//  Created by 최지우 on 11/8/24.
//

import Foundation

enum RestaurantType {
    case change
    case fix
}

enum Restaurant {
    case dodamRestaurant
    case dormitoryRestaurant
    case studentRestaurant
    case snackCorner

    var type: RestaurantType {
        switch self {
        case .dodamRestaurant, .dormitoryRestaurant, .studentRestaurant:
            return .change
        case .snackCorner:
            return .fix
        }
    }

    var identifier: String {
        switch self {
        case .dodamRestaurant:
            return "DODAM"
        case .dormitoryRestaurant:
            return "DORMITORY"
        case .studentRestaurant:
            return "HAKSIK"
        case .snackCorner:
            return "SNACK_CORNER"
        }
    }
}
