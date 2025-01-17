//
//  MediumView.swift
//  Widget
//
//  Created by JIWOONG CHOI on 1/17/25.
//

import EATSSUDesign
import SwiftUI

struct MediumView: View {
    var entry: ESEntry

    var body: some View {
        VStack {
            HStack {
                Text("화")
                    .font(EATSSUDesignFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                Text("중식")
                    .font(EATSSUDesignFontFamily.Pretendard.regular.swiftUIFont(size: 10))
                Spacer()
                Image(asset: EATSSUDesignAsset.Images.Version2.mainLogoSmall)
                    .resizable()
                    .frame(width: 44, height: 14)
            }

            HStack {
                Text("기숙사 식당")
                    .font(EATSSUDesignFontFamily.Pretendard.regular.swiftUIFont(size: 10))
                Spacer()
                Text("9월 26일")
                    .font(EATSSUDesignFontFamily.Pretendard.regular.swiftUIFont(size: 10))
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 0) {
                ForEach(0 ..< 10, id: \.self) { index in
                    Text("메뉴 \(index + 1)")
                        .font(EATSSUDesignFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(EATSSUDesignAsset.Color.GrayScale.gray300.swiftUIColor)
            }
        }
    }
}
