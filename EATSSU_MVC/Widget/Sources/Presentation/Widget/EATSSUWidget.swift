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
    let kind: String = "EATSSUWidget"

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
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    EATSSUWidget()
} timeline: {
    SimpleEntry(date: .now, data: "Small Preview Data")
}

#Preview(as: .systemMedium) {
    EATSSUWidget()
} timeline: {
    SimpleEntry(date: .now, data: "Medium Preview Data")
}

#Preview(as: .systemLarge) {
    EATSSUWidget()
} timeline: {
    SimpleEntry(date: .now, data: "Large Preview Data")
}