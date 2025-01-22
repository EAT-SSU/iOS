//
//  ESTimelineProvider.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 12/31/24.
//

import WidgetKit

import Moya
import RxMoya
import RxSwift

struct ESTimelineProvider: AppIntentTimelineProvider {
    typealias Intent = SelectRestaurant
    typealias Entry = ESEntry

    private let disposeBag = DisposeBag()

    func placeholder(in _: Context) -> ESEntry {
        ESEntry(date: Date(), restaurantName: "기숙사 식당")
    }

    func snapshot(for configuration: SelectRestaurant, in _: Context) async -> ESEntry {
        ESEntry(date: Date(), restaurantName: configuration.selectedRestaurant.displayName)
    }

    func timeline(for configuration: SelectRestaurant, in _: Context) async -> Timeline<ESEntry> {
        let currentDate = Date()
        let formattedDate = formatDate(currentDate)
        let restaurant = configuration.selectedRestaurant.rawValue
        let timeSlot = getTimeSlot(for: currentDate)

        print("Requesting menu for date: \(formattedDate), restaurant: \(restaurant), time: \(timeSlot)")

        let initialEntry = ESEntry(date: currentDate, restaurantName: configuration.selectedRestaurant.displayName)
        var timeline = Timeline(entries: [initialEntry], policy: .after(currentDate.addingTimeInterval(60 * 60)))

        let provider = MoyaProvider<HomeRouter>()

        do {
            let menus = try await fetchMenu(provider: provider, date: formattedDate, restaurant: restaurant, time: timeSlot)
            let updatedEntry = ESEntry(date: currentDate, restaurantName: configuration.selectedRestaurant.displayName, menus: menus)
            timeline = Timeline(entries: [updatedEntry], policy: .after(currentDate.addingTimeInterval(60 * 60)))
        } catch {
            print("Error: \(error.localizedDescription)")
        }

        return timeline
    }

    private func fetchMenu(provider: MoyaProvider<HomeRouter>, date: String, restaurant: String, time: String) async throws -> [String] {
        try await withCheckedThrowingContinuation { continuation in
            provider.rx.request(.getChangeMenuTableResponse(date: date, restaurant: restaurant, time: time))
                .map(BaseResponse<[ChangeMenuTableResponse]>.self)
                .subscribe(onSuccess: { response in
                    let menuNames = response.result.flatMap { $0.briefMenus.map(\.name) }
                    continuation.resume(returning: menuNames)
                }, onFailure: { error in
                    print("RxMoya Error: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                })
                .disposed(by: disposeBag)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: date)
    }

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
