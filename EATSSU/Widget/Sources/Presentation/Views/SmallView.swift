//
//  SmallView.swift
//  Widget
//
//  Created by JIWOONG CHOI on 1/17/25.
//

import SwiftUI

import EATSSUDesign

struct SmallView: View {
    var entry: ESEntry

    var body: some View {
        if entry.isError {
            SmallErrorView(entry: entry)
        } else {
            SmallSuccessView(entry: entry)
        }
    }
}
