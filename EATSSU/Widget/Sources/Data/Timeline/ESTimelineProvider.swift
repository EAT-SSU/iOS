//
//  ESTimelineProvider.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 12/31/24.
//

import Combine
import WidgetKit

import Moya

// 위젯의 타임라인 데이터를 제공하는 프로바이더 구조체
struct ESTimelineProvider: AppIntentTimelineProvider {
    typealias Intent = SelectRestaurant // 사용자가 선택한 식당 정보를 저장하는 인텐트
    typealias Entry = ESEntry // 위젯에 표시될 데이터 구조체

    private let userDefaults = UserDefaults(suiteName: Bundle.main.infoDictionary?["AppGroupID"] as? String)
    
    // 위젯이 처음 로드될 때 보여줄 기본 데이터
    func placeholder(in _: Context) -> ESEntry {
        let currentDate = Date()
        let timeSlot = getTimeSlot(for: currentDate)
        return ESEntry(
            date: currentDate,
            restaurantName: "학생식당",
            timeSlot: timeSlot,
            isError: false
        )
    }

    // 위젯 미리보기에서 사용할 샘플 데이터 제공
    func snapshot(for _: SelectRestaurant, in _: Context) async -> ESEntry {
        let mockupMenus = ["스팸마요덮밥", "우동국물", "깍두기", "요거트",
                           "불고기덮밥", "된장찌개", "참치김치볶음",
                           "배추김치", "계란장조림", "사과"]
        return ESEntry(
            date: Date(),
            restaurantName: "학생식당",
            menus: mockupMenus,
            timeSlot: "LUNCH",
            isError: false
        )
    }
    

    // 위젯의 타임라인 데이터를 제공하는 함수
    func timeline(for configuration: SelectRestaurant, in context: Context) async -> Timeline<ESEntry> {
        if !context.isPreview {
            checkForWidgetEvents(configuration: configuration)
        }
        let updateInterval: TimeInterval = 60 * 60 // 1시간마다 업데이트
        let currentDate = Date()
        let formattedDate = formatDate(currentDate) // 현재 날짜를 문자열로 변환
        let restaurant = configuration.selectedRestaurant.rawValue // 선택된 식당의 rawValue
        let timeSlot = getTimeSlot(for: currentDate) // 현재 시간에 따른 타임슬롯 설정 (아침, 점심, 저녁)

        #if DEBUG
            print("Requesting menu for date: \(formattedDate), restaurant: \(restaurant), time: \(timeSlot)")
        #endif

        // 초기 기본 엔트리 생성 (네트워크 요청 이전 기본값)
        let initialEntry = ESEntry(
            date: currentDate,
            restaurantName: configuration.selectedRestaurant.displayName,
            timeSlot: timeSlot
        )
        var timeline = Timeline(entries: [initialEntry], policy: .after(currentDate.addingTimeInterval(updateInterval)))

        let provider = MoyaProvider<HomeRouter>() // Moya를 이용한 네트워크 요청 객체 생성

        do {
            // 네트워크 요청을 통해 메뉴 데이터를 가져옴
            let menus = try await fetchMenu(provider: provider, date: formattedDate, restaurant: restaurant, time: timeSlot)
            let updatedEntry = ESEntry(
                date: currentDate,
                restaurantName: configuration.selectedRestaurant.displayName,
                menus: menus,
                timeSlot: timeSlot
            )

            // 새로운 데이터로 타임라인 업데이트
            timeline = Timeline(entries: [updatedEntry], policy: .atEnd)
        } catch {
            #if DEBUG
                print("Error: \(error.localizedDescription)") // 네트워크 요청 실패 시 오류 출력
            #endif

            let errorEntry = ESEntry(
                date: currentDate,
                restaurantName: configuration.selectedRestaurant.displayName,
                menus: ["네트워크 연결 실패"],
                timeSlot: timeSlot,
                isError: true
            )
            timeline = Timeline(entries: [errorEntry], policy: .atEnd)
        }

        return timeline
    }
    
    private func checkForWidgetEvents(configuration: SelectRestaurant) {
        let newRestaurant = configuration.selectedRestaurant.displayName
        let lastRestaurantKey = "lastSelectedRestaurantForAnalytics"
        if let oldRestaurant = userDefaults?.string(forKey: lastRestaurantKey) {
            if oldRestaurant != newRestaurant {
                WidgetAnalyticsManager.shared.recordWidgetChanged(before: oldRestaurant, after: newRestaurant)
            }
        } else {
            WidgetAnalyticsManager.shared.recordWidgetAdded()
        }
        userDefaults?.set(newRestaurant, forKey: lastRestaurantKey)
    }


    // 서버에서 특정 날짜, 식당, 시간대의 메뉴 정보를 가져오는 함수
    private func fetchMenu(provider: MoyaProvider<HomeRouter>, date: String, restaurant: String, time: String) async throws -> [String] {
        let response = try await provider.request(.getChangeMenuTableResponse(date: date, restaurant: restaurant, time: time))
        let decoded = try response.map(BaseResponse<[ChangeMenuTableResponse]>.self)
        return decoded.result.flatMap { $0.briefMenus.map(\.name) }
    }

    // Date 객체를 "yyyyMMdd" 형식의 문자열로 변환하는 함수
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: date)
    }

    // 현재 시간을 기준으로 아침, 점심, 저녁을 구분하는 함수
    private func getTimeSlot(for date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 0 ..< 10: return "MORNING"
        case 10 ..< 16: return "LUNCH"
        case 16 ..< 24: return "DINNER"
        default: return "CLOSED"
        }
    }
}

// MARK: - Moya Async Extension
extension MoyaProvider {
    func request(_ target: Target) async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            self.request(target) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
