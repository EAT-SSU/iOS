//
//  EATSSUWidget.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 12/31/24.
//

import SwiftUI
import WidgetKit

@available(iOS 17.0, *)
@main
struct EATSSUWidget: Widget {
    let kind: String = "EATSSU"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectRestaurant.self, // SelectRestaurant Intent 사용
            provider: ESTimelineProvider()
        ) { entry in
            if #available(iOS 17.0, *) {
                WidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("EATSSU 위젯")
        .description("확인하고 싶은 식당을 선택하세요.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
