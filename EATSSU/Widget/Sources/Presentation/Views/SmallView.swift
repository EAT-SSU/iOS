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
        VStack {
            HStack {
                Text(entry.restaurantName)
                    .font(EATSSUDesignFontFamily.Pretendard.bold.swiftUIFont(size: 10))
                    .foregroundStyle(.black)
                    .dynamicTypeSize(.xLarge ... .xxxLarge)
                Text("중식")
                    .font(EATSSUDesignFontFamily.Pretendard.regular.swiftUIFont(size: 8))
                    .foregroundStyle(.black)
                    .dynamicTypeSize(.xLarge ... .xxxLarge)
                Spacer()
                Image(asset: EATSSUDesignAsset.Images.Version2.miniLogo)
                    .resizable()
                    .frame(width: 10, height: 10)
            }

            VStack {
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(EATSSUDesignAsset.Color.GrayScale.gray100.swiftUIColor)
            )
        }
        .background(Color.white)
    }
}
