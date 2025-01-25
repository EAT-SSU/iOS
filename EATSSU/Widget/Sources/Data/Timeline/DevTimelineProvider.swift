//
//  DevTimelineProvider.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 1/25/25.
//

import WidgetKit

// 개발용 목업 데이터를 제공하는 타임라인 프로바이더
struct DevTimelineProvider: AppIntentTimelineProvider {
    typealias Intent = SelectRestaurant
    typealias Entry = ESEntry

    // 개발용 고정 메뉴 데이터
    private let mockMenus = [
        "아침 메뉴": [
            "현미밥", "된장찌개", "계란말이", "김치",
            "두부조림", "시금치나물", "연근조림",
            "미역국", "오이소박이", "콩자반",
        ],
        "점심 메뉴": [
            "스팸마요덮밥", "우동국물", "깍두기", "요거트",
            "불고기덮밥", "된장찌개", "참치김치볶음",
            "배추김치", "계란장조림", "사과",
        ],
        "저녁 메뉴": [
            "치킨텐더", "감자튀김", "콜슬로", "양상추샐러드",
            "스테이크", "그릴드치즈", "토마토스프",
            "브로콜리살라드", "마늘빵", "딸기요거트",
        ],
    ]

    func placeholder(in _: Context) -> ESEntry {
        ESEntry(date: Date(), restaurantName: "개발용 식당", menus: ["로딩중..."])
    }

    func snapshot(for configuration: SelectRestaurant, in _: Context) async -> ESEntry {
        ESEntry(date: Date(),
                restaurantName: configuration.selectedRestaurant.displayName,
                menus: ["샘플 메뉴 1", "샘플 메뉴 2"])
    }

    func timeline(for configuration: SelectRestaurant, in _: Context) async -> Timeline<ESEntry> {
        let currentDate = Date()
        let timeSlot = getTimeSlot(for: currentDate)

        // 시간대별 목업 데이터 생성
        let entry = switch timeSlot {
        case "MORNING":
            ESEntry(
                date: currentDate,
                restaurantName: configuration.selectedRestaurant.displayName,
                menus: mockMenus["아침 메뉴"] ?? []
            )
        case "LUNCH":
            ESEntry(
                date: currentDate,
                restaurantName: configuration.selectedRestaurant.displayName,
                menus: mockMenus["점심 메뉴"] ?? []
            )
        case "DINNER":
            ESEntry(
                date: currentDate,
                restaurantName: configuration.selectedRestaurant.displayName,
                menus: mockMenus["저녁 메뉴"] ?? []
            )
        default:
            ESEntry(
                date: currentDate,
                restaurantName: configuration.selectedRestaurant.displayName,
                menus: ["영업시간이 아닙니다"]
            )
        }

        // 5분마다 업데이트 (개발용 빠른 주기)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    // 시간대 계산 메서드 (ESTimelineProvider와 동일)
    private func getTimeSlot(for date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 0 ..< 10: return "MORNING"
        case 10 ..< 15: return "LUNCH"
        case 15 ..< 21: return "DINNER"
        default: return "CLOSED"
        }
    }
}

// 프리뷰용 확장
#Preview(as: .systemSmall) {
    EATSSUWidget()
} timeline: {
    ESEntry(date: Date(), restaurantName: "개발용 식당", menus: ["메뉴1", "메뉴2", "메뉴3"])
}
