//
//  ESTimelineProvider.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 12/31/24.
//

import WidgetKit

import RxSwift

final class ESTimelineProvider: TimelineProvider {
    private let disposeBag = DisposeBag()

    func placeholder(in _: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), someString: "Loading...")
    }

    func getSnapshot(in _: Context, completion: @escaping (SimpleEntry) -> Void) {
        let cachedData = CacheManager.shared.fetchCachedData() ?? "Fallback Data"
        completion(SimpleEntry(date: Date(), someString: cachedData))
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let formattedDate = dateFormatter.string(from: currentDate)

        let restaurant = "DORMITORY"
        let time: String
        let currentTime = Calendar.current.component(.hour, from: currentDate)

        switch currentTime {
        case 0 ..< 10:
            time = "MORNING"
        case 10 ..< 15:
            time = "LUNCH"
        case 15 ..< 21:
            time = "DINNER"
        default:
            time = "LUNCH"
        }

        let apiClient = APIClient()

        apiClient.fetchChangeMenuTableResponse(date: formattedDate, restaurant: restaurant, time: time)
            .subscribe(onSuccess: { response in
                let result = response.result
                for changeMenuTableResponse in result {
                    for briefMenu in changeMenuTableResponse.briefMenus {
                        print(briefMenu.name)
                    }
                    print("")
                }
                let entry = SimpleEntry(date: currentDate, someString: time)
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
            }, onFailure: { error in
                print("Error fetching menu data: \(error.localizedDescription)")
                // Fallback to cached or placeholder data
                let entry = SimpleEntry(date: currentDate, someString: "실패")
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
            })
            .disposed(by: disposeBag)
    }
}
