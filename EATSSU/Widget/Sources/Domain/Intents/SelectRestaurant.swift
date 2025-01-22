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

/// 레스토랑 옵션을 정의하는 열거형
///
/// 사용자가 선택할 수 있는 식당 옵션을 정의합니다.
///
/// - dodam: 도담식당
/// - haksik: 학생식당
/// - dormitory: 기숙사 식당
enum RestaurantOptions: String, AppEnum {
    /// 도담식당
    case dodam = "DODAM"

    /// 학생식당
    case haksik = "HAKSIK"

    /// 기숙사 식당
    case dormitory = "DORMITORY"

    /// 위젯 UI에 렌더링할 텍스트
    var displayName: String {
        switch self {
        case .dodam:
            "도담식당"
        case .haksik:
            "학생식당"
        case .dormitory:
            "기숙사 식당"
        }
    }

    /// 옵션 타입의 표시 표현을 정의합니다.
    ///
    /// - Returns: "Restaurant Options" 문자열을 반환합니다.
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Restaurant Options"
    }

    /// 각 옵션에 대한 사용자 친화적인 설명을 제공합니다.
    ///
    /// - Returns: 각 옵션에 대한 로컬라이징 가능한 제목을 포함하는 사전
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .dodam: DisplayRepresentation(title: "도담식당"),
            .haksik: DisplayRepresentation(title: "학생식당"),
            .dormitory: DisplayRepresentation(title: "기숙사 식당"),
        ]
    }
}

/// 위젯 구성 인텐트를 정의하는 구조체
///
/// 이 구조체는 위젯이 특정 식당을 선택하도록 하는 역할을 수행합니다.
struct SelectRestaurant: WidgetConfigurationIntent {
    /// 위젯의 제목
    ///
    /// - Returns: "Select Restaurant" 문자열을 반환합니다.
    static var title: LocalizedStringResource {
        "Select Restaurant"
    }

    /// 위젯의 설명
    ///
    /// - Returns: 사용자가 선택할 수 있는 식당 목록에 대한 설명을 제공
    static var description: IntentDescription {
        IntentDescription("Choose between Dodam, Haksik, or Dormitory.")
    }

    /// 사용자가 선택할 식당 옵션
    ///
    /// 기본적으로 "학생식당"이 선택됩니다.
    ///
    /// - Parameter title: UI에 표시될 타이틀
    /// - Parameter description: 사용자가 식당을 선택할 때의 안내 메시지
    /// - Parameter default: 기본값은 `haksik` (학생식당)
    @Parameter(
        title: "선택된 식당",
        description: "식당을 선택하세요",
        default: RestaurantOptions.haksik
    )
    var selectedRestaurant: RestaurantOptions

    /// 사용자가 식당을 선택했을 때 수행되는 함수
    ///
    /// 선택된 식당의 값을 출력하고, 결과를 반환합니다.
    ///
    /// - Returns: 성공적인 수행 결과
    func perform() async throws -> some IntentResult {
        print("Selected restaurant: \(selectedRestaurant.rawValue)")
        return .result()
    }
}
