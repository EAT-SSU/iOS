//
//  ESTimelineProvider.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 12/31/24.
//

import WidgetKit

import Moya

struct ESTimelineProvider: AppIntentTimelineProvider {
    typealias Intent = SelectRestaurant // SelectRestaurant Intent 사용
    typealias Entry = ESEntry

    func placeholder(in _: Context) -> ESEntry {
        // 위젯의 기본 플레이스홀더 데이터 제공
        ESEntry(date: Date(), restaurantName: "기숙사 식당")
    }

    func snapshot(for configuration: SelectRestaurant, in _: Context) async -> ESEntry {
        // 위젯 미리보기 데이터 제공
        ESEntry(date: Date(), restaurantName: configuration.selectedRestaurant.displayName)
    }

    func timeline(for configuration: SelectRestaurant, in _: Context) async -> Timeline<ESEntry> {
        
        // TODO: Utility 프레임워크에 설계
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let formattedDate = dateFormatter.string(from: currentDate)

        let restaurant = configuration.selectedRestaurant.rawValue
        let timeSlot: String
        let currentHour = Calendar.current.component(.hour, from: currentDate)

        // 시간대에 따른 메뉴 구분
        switch currentHour {
        case 0 ..< 10:
            timeSlot = "MORNING"
        case 10 ..< 15:
            timeSlot = "LUNCH"
        case 15 ..< 21:
            timeSlot = "DINNER"
        default:
            timeSlot = "CLOSED"
        }

        // 기본 데이터를 반환 (초기 상태)
        let initialEntry = ESEntry(date: currentDate, restaurantName: configuration.selectedRestaurant.displayName)
        let timeline = Timeline(entries: [initialEntry], policy: .after(currentDate.addingTimeInterval(60 * 5)))

        print("Requesting menu for date: \(formattedDate), restaurant: \(restaurant), time: \(timeSlot)")
        
        // TODO: RxMoya로 구현하기
        let provider = MoyaProvider<HomeRouter>(plugins: [])
        provider
            .request(
                .getChangeMenuTableResponse(
                    date: formattedDate,
                    restaurant: restaurant,
                    time: timeSlot
                )
            ) { result in
                switch result {
                case .success(let response):
                    print("Status Code : \(response.statusCode)")
                    do {
                        let decodedResponse = try response.map(BaseResponse<[ChangeMenuTableResponse]>.self)
                        for changeMenuTableResponse in decodedResponse.result {
                            for briefMenu in changeMenuTableResponse.briefMenus {
                                print(briefMenu.name)
                            }
                        }
                    } catch {
                        print("Error : \(error.localizedDescription)")
                    }
                case .failure(let error):
                    print("Error : \(error.localizedDescription)")
                }
        }

        return timeline
    }
}
