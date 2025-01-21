//
//  ESTimelineProvider.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 12/31/24.
//

import WidgetKit

import RxMoya
import RxSwift

struct ESTimelineProvider: AppIntentTimelineProvider {
    typealias Intent = SelectRestaurant // SelectRestaurant Intent 사용
    typealias Entry = ESEntry

    func placeholder(in _: Context) -> ESEntry {
        // 위젯의 기본 플레이스홀더 데이터 제공
        ESEntry(date: Date(), restaurantName: "Loading...")
    }

    func snapshot(for configuration: SelectRestaurant, in _: Context) async -> ESEntry {
        // 위젯 미리보기 데이터 제공
        ESEntry(date: Date(), restaurantName: configuration.selectedRestaurant.rawValue)
    }

    func timeline(for configuration: SelectRestaurant, in _: Context) async -> Timeline<ESEntry> {
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
        let initialEntry = ESEntry(date: currentDate, restaurantName: "Fetching menu...")
        let timeline = Timeline(entries: [initialEntry], policy: .after(currentDate.addingTimeInterval(60 * 5)))

        print("Requesting menu for date: \(formattedDate), restaurant: \(restaurant), time: \(timeSlot)")

        // RxSwift를 이용한 비동기 작업
        APIClient().fetchChangeMenuTableResponse(date: formattedDate, restaurant: restaurant, time: timeSlot)
            .subscribe { response in
                let result = response.result
                let menuNames = result.flatMap { $0.briefMenus.map(\.name) }
                let menuString = menuNames.joined(separator: ", ")

                // 디버깅용 프린트 추가
                print("Fetched menu names: \(menuString)")

                // UI 업데이트용 새로운 타임라인 생성
                let newEntry = ESEntry(date: Date(), restaurantName: menuString)
                let updatedTimeline = Timeline(entries: [newEntry], policy: .atEnd)

                // 위젯을 새로고침하기 위해 위젯 센터에 업데이트 요청
                WidgetCenter.shared.reloadAllTimelines()
            } onFailure: { error in
                print("Error : \(error.localizedDescription)")
            } onDisposed: {
                print("Observable disposed")
            }
            .disposed(by: DisposeBag())

        return timeline
    }
}
