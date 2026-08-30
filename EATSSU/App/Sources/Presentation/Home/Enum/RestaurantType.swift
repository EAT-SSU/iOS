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

/// rawValue는 Localizable.strings `restaurantInfo.<rawValue>.*` 키로도 사용된다
enum Restaurant: String, CaseIterable {
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

    /// 현재 앱 언어로 표시되는 식당 이름
    var title: String {
        switch self {
        case .dodamRestaurant:
            TextLiteral.Restaurant.dodamRestaurant
        case .dormitoryRestaurant:
            TextLiteral.Restaurant.dormitoryRestaurant
        case .studentRestaurant:
            TextLiteral.Restaurant.studentRestaurant
        case .snackCorner:
            TextLiteral.Restaurant.snackCorner
        case .facultyRestaurant:
            TextLiteral.Restaurant.facultyRestaurant
        }
    }

    /// Firebase Remote Config `cafeteria_information`의 `name`과 매칭하기 위한 한국어 이름
    // TODO: Remote Config에 id가 추가되면 이름 대신 id로 매칭하도록 변경
    var koreanName: String {
        switch self {
        case .dodamRestaurant:
            "도담 식당"
        case .dormitoryRestaurant:
            "기숙사 식당"
        case .studentRestaurant:
            "학생 식당"
        case .snackCorner:
            "스낵 코너"
        case .facultyRestaurant:
            "FACULTY (교직원 전용)"
        }
    }

    /// 화면에 표시된 식당 이름(현재 언어)으로 역조회
    init?(title: String) {
        guard let match = Self.allCases.first(where: { $0.title == title }) else { return nil }
        self = match
    }
}
