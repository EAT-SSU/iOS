//
//  LikedPartnershipMockData.swift
//  EATSSU
//
//  Created by 황상환 on 8/30/26.
//

import Foundation

#if DEBUG
/// 서버에 찜 데이터가 없는 동안 찜 목록 UI 확인용 목 데이터 (DEBUG 전용, id는 음수)
enum LikedPartnershipMockData {

    static let samples: [PartnershipDTO] = [
        store("맘스터치 숭실대점", type: "RESTAURANT", lat: 37.4963, lng: 126.9572, infos: [
            info(-101, college: "IT대학", desc: "학생증 인증하면 음료수 1개 증정"),
            info(-102, department: "컴퓨터학부", desc: "세트 메뉴 10% 할인")
        ]),
        store("스타벅스 숭실대입구역점", type: "CAFE", lat: 37.4959, lng: 126.9538, infos: [
            info(-103, college: "경영대학", desc: "아메리카노 사이즈업 무료")
        ]),
        store("역전할머니맥주 숭실대점", type: "PUB", lat: 37.4945, lng: 126.9581, infos: [
            info(-104, college: "인문대학", desc: "4인 이상 방문 시 안주 1개 서비스"),
            info(-105, department: "영어영문학과", desc: "생맥주 500cc 1+1")
        ]),
        store("이레김밥", type: "RESTAURANT", lat: 37.4952, lng: 126.9549, infos: [
            info(-106, college: "자연과학대학", desc: "김밥 한 줄 500원 할인")
        ]),
        store("카페봄봄 숭실대점", type: "CAFE", lat: 37.4967, lng: 126.9555, infos: [
            info(-107, college: "공과대학", desc: "학생증 인증 시 모든 음료 10% 할인 및 텀블러 지참 시 추가 할인")
        ]),
        store("파동추야", type: "PUB", lat: 37.4941, lng: 126.9560, infos: [
            info(-108, college: "사회과학대학", desc: "소주·맥주 1병 무료")
        ])
    ]

    private static func store(
        _ name: String, type: String, lat: Double, lng: Double, infos: [PartnershipInfoDTO]
    ) -> PartnershipDTO {
        PartnershipDTO(
            storeName: name,
            longitude: lng,
            latitude: lat,
            restaurantType: type,
            naverMapUrl: nil,
            kakaoMapUrl: nil,
            partnershipInfos: infos
        )
    }

    private static func info(
        _ id: Int, college: String? = nil, department: String? = nil, desc: String
    ) -> PartnershipInfoDTO {
        PartnershipInfoDTO(
            id: id,
            collegeName: college,
            departmentName: department,
            likeCount: 1,
            isLiked: true,
            description: desc,
            startDate: "2026-09-01",
            endDate: "2026-12-31",
            periodType: .normal
        )
    }
}
#endif
