//
//  WidgetEntryView.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 12/31/24.
//

import SwiftUI

struct WidgetEntryView: View {
    var entry: SimpleEntry

    var body: some View {
        VStack {
            if entry.someString.isEmpty {
                Text("Data:")
                Text("nil 방지")
                    .font(.headline)
            } else {
                Text("Data:")
                Text(entry.someString)
                    .font(.headline)
            }
        }
        .padding()
    }
}
