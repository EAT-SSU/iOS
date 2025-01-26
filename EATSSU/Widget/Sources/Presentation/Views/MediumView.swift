//
//  MediumView.swift
//  Widget
//
//  Created by JIWOONG CHOI on 1/17/25.
//

import SwiftUI

import EATSSUDesign

struct MediumView: View {
    var entry: ESEntry

    var body: some View {
        if entry.isError {
            MediumErrorView(entry: entry)
        } else {
            if entry.menus.isEmpty {
                MediumEmptyMenuView(entry: entry)
            } else {
                MediumNormalView(entry: entry)
            }
        }
    }
}
