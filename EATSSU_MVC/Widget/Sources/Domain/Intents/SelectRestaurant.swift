//
//  SelectRestaurant.swift
//  Widget
//
//  Created by JIWOONG CHOI on 1/19/25.
//

import AppIntents
import Foundation
import SwiftUI
import WidgetKit

// 레스토랑 옵션을 정의하는 Enum
enum RestaurantOptions: String, AppEnum {
    case dodam = "DODAM"
    case haksik = "HAKSIK"
    case dormitory = "DORMITORY"

    // 옵션 이름을 표시하기 위한 속성
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Restaurant Options"
    }

    // 각각의 옵션에 대해 사용자 친화적인 설명 추가
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .dodam: DisplayRepresentation(title: "도담식당"),
            .haksik: DisplayRepresentation(title: "학생식당"),
            .dormitory: DisplayRepresentation(title: "기숙사 식당")
        ]
    }
}

// WidgetConfigurationIntent를 구현하는 구조체
struct SelectRestaurant: WidgetConfigurationIntent {
    static var title: LocalizedStringResource {
        "Select Restaurant"
    }

    static var description: IntentDescription {
        IntentDescription("Choose between Dodam, Haksik, or Dormitory.")
    }

    @Parameter(
        title: "선택된 식당",
        description: "식당을 선택하세요",
        default: .haksik // 기본값 설정
    )
    var selectedRestaurant: RestaurantOptions

    func perform() async throws -> some IntentResult {
        // 선택한 옵션을 기반으로 동작을 정의
        print("Selected restaurant: \(selectedRestaurant.rawValue)")
        return .result()
    }
}
