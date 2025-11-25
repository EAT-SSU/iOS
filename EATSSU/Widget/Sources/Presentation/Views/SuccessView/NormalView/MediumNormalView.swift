//
//  MediumNormalView.swift
//  EATSSUWidget
//
//  Created by JIWOONG CHOI on 1/26/25.
//

import SwiftUI

import EATSSUDesign

struct MediumNormalView: View {
    var entry: ESEntry

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(entry.restaurantName)
                    .font(EATSSUDesignFontFamily.Pretendard.bold.swiftUIFont(size: 12))
                    .foregroundStyle(.black)
                    .dynamicTypeSize(.xLarge ... .xxxLarge)

                if entry.timeSlot == "MORNING" || entry.timeSlot == "LUNCH" || entry.timeSlot == "DINNER" {
                    Text(entry.timeSlot == "MORNING" ? "조식" : entry.timeSlot == "LUNCH" ? "중식" : "석식")
                        .font(EATSSUDesignFontFamily.Pretendard.regular.swiftUIFont(size: 10))
                        .foregroundStyle(.black)
                        .dynamicTypeSize(.xLarge ... .xxxLarge)
                }

                Spacer()

                Image(asset: EATSSUDesignAsset.Images.mainLogoSmall)
                    .resizable()
                    .frame(width: 44, height: 14)
            }
            .padding(8)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(entry.menus.enumerated()), id: \.offset) { index, menuSet in
                    Text(menuSet.joined(separator: " + "))
                        .font(EATSSUDesignFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                        .foregroundStyle(.black)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .dynamicTypeSize(.xLarge ... .xxxLarge)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading) 
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(EATSSUDesignAsset.Color.GrayScale.gray100.swiftUIColor)
            )
        }
        .padding(12)
        .background(Color.white)
    }
}
