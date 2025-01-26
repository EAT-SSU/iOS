//
//  MediumErrorView.swift
//  EATSSUWidget
//
//  Created by JIWOONG CHOI on 1/26/25.
//

import SwiftUI

import EATSSUDesign

struct MediumErrorView: View {
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

                Image(asset: EATSSUDesignAsset.Images.mainLogoSmall)
                    .resizable()
                    .frame(width: 44, height: 14)
            }

            Spacer()

            VStack {
                Image(asset: EATSSUDesignAsset.Images.networkErrorWarningSign)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(EATSSUDesignAsset.Color.GrayScale.gray100.swiftUIColor)
            )
        }
        .background(Color.white)
    }
}
