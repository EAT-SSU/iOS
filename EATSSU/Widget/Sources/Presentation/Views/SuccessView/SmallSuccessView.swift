//
//  SmallSuccessView.swift
//  EATSSUWidget
//
//  Created by JIWOONG CHOI on 1/26/25.
//

import SwiftUI

import EATSSUDesign

struct SmallSuccessView: View {
    var entry: ESEntry

    var body: some View {
        Spacer()

        VStack {
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

                Image(asset: EATSSUDesignAsset.Images.miniLogo)
                    .resizable()
                    .frame(width: 10, height: 10)
            }

            Spacer()

            VStack {
                if entry.menus.isEmpty {
                    Image(asset: EATSSUDesignAsset.Images.noMenuInfoSign)
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 10) {
                        ForEach(entry.menus.prefix(8), id: \.self) { menu in
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
