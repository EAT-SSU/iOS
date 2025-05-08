//
//  WidgetEntryView.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 12/31/24.
//

import SwiftUI
import WidgetKit

struct WidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: ESEntry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallView(entry: entry)
            case .systemMedium:
                MediumView(entry: entry)
            default:
                Text("Unsupported Widget Family")
            }
        }
        .onChange(of: family) { _, _ in
            WidgetCenter.shared.reloadAllTimelines()
        }
        .widgetURL(URL(string: "eatssu://from_widget"))
    }
}
