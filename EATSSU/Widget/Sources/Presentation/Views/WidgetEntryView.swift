//
//  WidgetEntryView.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 12/31/24.
//

import SwiftUI

struct WidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: ESEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallView(entry: entry)
        case .systemMedium:
            MediumView(entry: entry)
        default:
            Text("Unsupported Widget Family")
        }
    }
}
