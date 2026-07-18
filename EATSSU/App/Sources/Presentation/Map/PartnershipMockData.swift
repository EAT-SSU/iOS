//
//  PartnershipMockData.swift
//  EATSSU
//
//  Created by 황상환 on 7/18/26.
//

#if DEBUG
import Foundation

/// 서버에 제휴 데이터가 없을 때 실기기 테스트용 Mock 데이터 (DEBUG 빌드 전용)
enum PartnershipMockData {

    /// 숭실대 주변 가게 좌표 기반 샘플
    static let samples: [PartnershipDTO] = [
        PartnershipDTO(
            storeName: "맘스터치 숭실대점",
            longitude: 126.9550,
            latitude: 37.4959,
            restaurantType: "RESTAURANT",
            naverMapUrl: nil,
            kakaoMapUrl: nil,
            partnershipInfos: [
                PartnershipInfoDTO(
                    id: -1,
                    collegeName: "IT대학",
                    departmentName: nil,
                    likeCount: 0,
                    isLiked: false,
                    description: "학생증 인증하면 음료수 1개 증정",
                    startDate: "2025.09.03",
                    endDate: "2025.12.18",
                    periodType: .normal
                ),
                PartnershipInfoDTO(
                    id: -2,
                    collegeName: nil,
                    departmentName: "컴퓨터학부",
                    likeCount: 0,
                    isLiked: false,
                    description: "학생증 인증하고 카카오페이 결제 시 10% 할인",
                    startDate: "2025.09.01",
                    endDate: "2025.12.31",
                    periodType: .normal
                )
            ]
        ),
        PartnershipDTO(
            storeName: "스타벅스 숭실대입구역점",
            longitude: 126.9538,
            latitude: 37.4964,
            restaurantType: "CAFE",
            naverMapUrl: nil,
            kakaoMapUrl: nil,
            partnershipInfos: [
                PartnershipInfoDTO(
                    id: -3,
                    collegeName: "경영대학",
                    departmentName: nil,
                    likeCount: 0,
                    isLiked: false,
                    description: "아메리카노 사이즈업 무료",
                    startDate: "2025.09.03",
                    endDate: "2025.12.18",
                    periodType: .normal
                )
            ]
        ),
        PartnershipDTO(
            storeName: "역전할머니맥주 숭실대점",
            longitude: 126.9532,
            latitude: 37.4949,
            restaurantType: "PUB",
            naverMapUrl: nil,
            kakaoMapUrl: nil,
            partnershipInfos: [
                PartnershipInfoDTO(
                    id: -4,
                    collegeName: "벤처중소기업센터",
                    departmentName: nil,
                    likeCount: 0,
                    isLiked: false,
                    description: "4인 이상 방문 시 안주 1개 서비스",
                    startDate: "2025.09.03",
                    endDate: "2025.12.18",
                    periodType: .normal
                ),
                PartnershipInfoDTO(
                    id: -5,
                    collegeName: "총학생회",
                    departmentName: nil,
                    likeCount: 0,
                    isLiked: false,
                    description: "축제 기간 병맥주 1+1",
                    startDate: "2025.10.06",
                    endDate: "2025.10.08",
                    periodType: .festival
                )
            ]
        )
    ]
}
#endif
