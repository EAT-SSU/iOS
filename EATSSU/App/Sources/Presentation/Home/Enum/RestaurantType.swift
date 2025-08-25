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
    case facultyRestaurant
    case snackCorner

    var type: RestaurantType {
        switch self {
        case .dodamRestaurant, .dormitoryRestaurant, .studentRestaurant, .facultyRestaurant:
            .change
        case .snackCorner:
            .fix
        }
    }

    var identifier: String {
        switch self {
        case .dodamRestaurant:
            "DODAM"
        case .dormitoryRestaurant:
            "DORMITORY"
        case .studentRestaurant:
            "HAKSIK"
        case .snackCorner:
            "SNACK_CORNER"
        case .facultyRestaurant:
            "FACULTY"
        }
    }
}
