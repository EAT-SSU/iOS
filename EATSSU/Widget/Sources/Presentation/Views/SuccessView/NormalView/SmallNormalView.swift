//
//  SmallNormalView.swift
//  EATSSUWidget
//
//  Created by JIWOONG CHOI on 1/26/25.
//

import SwiftUI

import EATSSUDesign

struct SmallNormalView: View {
    var entry: ESEntry

    var body: some View {
        VStack(spacing: 8) {
            // 상단 헤더 영역 (식당 이름, 시간, 로고)
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
            .padding(8)

            // 메인 콘텐츠 영역 (메뉴 리스트)
            VStack {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(entry.menus, id: \.self) { menuSet in
                        // 하나의 세트 안에 있는 반찬들을 " + "로 연결
                        Text(menuSet.joined(separator: " + "))
                            .font(EATSSUDesignFontFamily.Pretendard.medium.swiftUIFont(size: 11))
                            .foregroundStyle(.black)
                            .lineLimit(nil) 
                            .multilineTextAlignment(.leading)
                            .dynamicTypeSize(.xLarge ... .xxxLarge)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
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
