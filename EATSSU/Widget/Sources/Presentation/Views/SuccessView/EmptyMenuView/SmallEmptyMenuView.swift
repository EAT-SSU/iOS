//
//  SmallEmptyMenuView.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 1/26/25.
//

import SwiftUI

import EATSSUDesign

struct SmallEmptyMenuView: View {
    var entry: ESEntry

    var body: some View {
        VStack(spacing: 8) {
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

                Spacer(minLength: 4)

                Image(asset: EATSSUDesignAsset.Images.miniLogo)
                    .resizable()
                    .frame(width: 10, height: 10)
            }
            .padding(.horizontal, 8)

            VStack {
                Spacer(minLength: 0)
                
                Image(asset: EATSSUDesignAsset.Images.noMenuInfoSign)
                
                Spacer(minLength: 0)
            }
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
