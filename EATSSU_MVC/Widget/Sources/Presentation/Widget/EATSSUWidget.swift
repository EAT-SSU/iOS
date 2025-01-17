//
//  EATSSUWidget.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 12/31/24.
//

import SwiftUI
import WidgetKit

@main
struct EATSSUWidget: Widget {
    let kind: String = "EATSSU"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ESTimelineProvider()) { entry in
            if #available(iOS 17.0, *) {
                WidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("EATSSU Widget")
        .description("Displays dynamic data.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@available(iOS 17.0, *)
#Preview(as: .systemSmall, widget: {
    EATSSUWidget()
}, timelineProvider: {
    ESTimelineProvider()
})

@available(iOS 17.0, *)
#Preview(as: .systemMedium, widget: {
    EATSSUWidget()
}, timelineProvider: {
    ESTimelineProvider()
})
