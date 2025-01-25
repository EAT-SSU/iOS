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
            HStack {
                Text("화")
                    .font(EATSSUDesignFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(.black)
                    .dynamicTypeSize(.xLarge ... .xxxLarge)
                Text("중식")
                    .font(EATSSUDesignFontFamily.Pretendard.regular.swiftUIFont(size: 10))
                    .foregroundStyle(.black)
                    .dynamicTypeSize(.xLarge ... .xxxLarge)
                Spacer()
                Image(asset: EATSSUDesignAsset.Images.Version2.mainLogoSmall)
                    .resizable()
                    .frame(width: 44, height: 14)
            }

            HStack {
                Text(entry.restaurantName)
                    .font(EATSSUDesignFontFamily.Pretendard.regular.swiftUIFont(size: 10))
                    .foregroundStyle(.black)

                Spacer()

                Text("9월 26일")
                    .font(EATSSUDesignFontFamily.Pretendard.regular.swiftUIFont(size: 10))
                    .foregroundStyle(.black)
                    .dynamicTypeSize(.xLarge ... .xxxLarge)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 10) {
                ForEach(entry.menus, id: \.self) { menu in
                    Text(menu)
                        .font(EATSSUDesignFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .dynamicTypeSize(.xLarge ... .xxxLarge)
                }
            }
            .background(EATSSUDesignAsset.Color.GrayScale.gray100.swiftUIColor)

            Spacer()
        }
        .background(Color.white)
    }
}
