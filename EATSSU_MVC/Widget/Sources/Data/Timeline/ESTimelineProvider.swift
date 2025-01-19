//
//  ESTimelineProvider.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 12/31/24.
//

import WidgetKit

struct ESTimelineProvider: AppIntentTimelineProvider {
    typealias Intent = SelectRestaurant // SelectRestaurant Intent 사용
    typealias Entry = ESEntry

    func placeholder(in context: Context) -> ESEntry {
        // 위젯의 기본 플레이스홀더 데이터 제공
        ESEntry(date: Date(), restaurantName: "Loading...")
    }

    func snapshot(for configuration: SelectRestaurant, in context: Context) async -> ESEntry {
        // 위젯 미리보기 데이터 제공
        ESEntry(date: Date(), restaurantName: configuration.selectedRestaurant.rawValue)
    }

    func timeline(for configuration: SelectRestaurant, in context: Context) async -> Timeline<ESEntry> {
        // 사용자가 선택한 데이터를 기반으로 타임라인 생성
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let formattedDate = dateFormatter.string(from: currentDate)

        let restaurant = configuration.selectedRestaurant.rawValue
        let timeSlot: String
        let currentHour = Calendar.current.component(.hour, from: currentDate)

        // 시간대에 따라 메뉴 구분
        switch currentHour {
        case 0..<10:
            timeSlot = "MORNING"
        case 10..<15:
            timeSlot = "LUNCH"
        case 15..<21:
            timeSlot = "DINNER"
        default:
            timeSlot = "CLOSED"
        }

        // API 클라이언트 사용 (네트워크 요청 예제)
        do {
            let menuData = try await fetchMenu(for: formattedDate, restaurant: restaurant, timeSlot: timeSlot)
            let entry = ESEntry(date: currentDate, restaurantName: "\(restaurant) - \(timeSlot)", menu: menuData)
            return Timeline(entries: [entry], policy: .atEnd)
        } catch {
            print("Failed to fetch menu: \(error)")
            let entry = ESEntry(date: currentDate, restaurantName: "Error fetching data")
            return Timeline(entries: [entry], policy: .atEnd)
        }
    }

    // API 데이터를 비동기로 가져오는 함수
    private func fetchMenu(for date: String, restaurant: String, timeSlot: String) async throws -> String {
        // 예제: 실제 API 클라이언트 호출로 대체 가능
        // 여기서는 간단히 시간과 식당 데이터를 합쳐서 반환
        return "\(restaurant) menu for \(timeSlot) on \(date)"
    }
}

