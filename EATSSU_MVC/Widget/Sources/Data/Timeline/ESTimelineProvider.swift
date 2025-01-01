//
//  ESTimelineProvider.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 12/31/24.
//

import WidgetKit

final class ESTimelineProvider: TimelineProvider {
    func placeholder(in _: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), data: "Loading...")
    }

    func getSnapshot(in _: Context, completion: @escaping (SimpleEntry) -> Void) {
        let cachedData = CacheManager.shared.fetchCachedData() ?? "Fallback Data"
        completion(SimpleEntry(date: Date(), data: cachedData))
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let currentDate = Date()

        let entry = SimpleEntry(date: currentDate, data: "바뀌는지 테스트")
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}
