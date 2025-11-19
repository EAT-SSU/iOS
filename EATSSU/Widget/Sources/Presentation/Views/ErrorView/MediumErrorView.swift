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

            VStack {
                Spacer(minLength: 0)
                
                Image(asset: EATSSUDesignAsset.Images.networkErrorInfoMediumSign)
                
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
