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
        VStack {
            Spacer()

            HStack {
                Text(entry.restaurantName)
                    .font(EATSSUDesignFontFamily.Pretendard.bold.swiftUIFont(size: 10))
                    .foregroundStyle(.black)
                    .dynamicTypeSize(.xLarge ... .xxxLarge)
                
                if entry.timeSlot == "MORNING" || entry.timeSlot == "LUNCH" || entry.timeSlot == "DINNER" {
                    Text(entry.timeSlot == "MORNING" ? "조식" : entry.timeSlot == "LUNCH" ? "중식" : "석식")
                        .font(EATSSUDesignFontFamily.Pretendard.regular.swiftUIFont(size: 8))
                        .foregroundStyle(.black)
                        .dynamicTypeSize(.xLarge ... .xxxLarge)
                }
                
                Spacer()
                
                Image(asset: EATSSUDesignAsset.Images.Version2.mainLogoSmall)
                    .resizable()
                    .frame(width: 44, height: 14)
            }

            Spacer()

            VStack {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 8) {
                    ForEach(entry.menus.prefix(10), id: \.self) { menu in
                        Text(menu)
                            .font(EATSSUDesignFontFamily.Pretendard.medium.swiftUIFont(size: 11))
                            .foregroundStyle(.black)
                            .lineLimit(1)
                            .dynamicTypeSize(.xLarge ... .xxxLarge)
                    }
                }
                .padding(5)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(EATSSUDesignAsset.Color.GrayScale.gray100.swiftUIColor)
            )
        }
        .background(Color.white)

        Spacer()
    }
}
