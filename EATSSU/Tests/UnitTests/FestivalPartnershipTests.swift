//
//  FestivalPartnershipTests.swift
//  EATSSUUnitTests
//
//  Created by 황상환 on 9/13/26.
//

import XCTest

@testable import EATSSU_DEV

/// 축제 제휴를 기존 학교 제휴와 함께 표시하기 위한 병합·구분 로직 검증
final class FestivalPartnershipTests: XCTestCase {

    // MARK: - Helpers

    private func makeInfo(id: Int, periodType: PartnershipPeriodType) -> PartnershipInfoDTO {
        PartnershipInfoDTO(
            id: id,
            collegeName: "IT대학",
            departmentName: nil,
            likeCount: 0,
            isLiked: false,
            description: "제휴 내용",
            startDate: "2026-09-15",
            endDate: "2026-09-16",
            periodType: periodType
        )
    }

    private func makeStore(
        name: String,
        type: String = "RESTAURANT",
        infos: [PartnershipInfoDTO]
    ) -> PartnershipDTO {
        PartnershipDTO(
            storeName: name,
            longitude: 126.95,
            latitude: 37.49,
            restaurantType: type,
            naverMapUrl: nil,
            kakaoMapUrl: nil,
            partnershipInfos: infos
        )
    }

    // MARK: - mergedPartnerships

    func test_내_학과_제휴와_축제_제휴가_한_목록으로_합쳐진다() {
        let mine = makeStore(name: "A", infos: [makeInfo(id: 1, periodType: .normal)])
        let festival = makeStore(name: "B", infos: [makeInfo(id: 2, periodType: .festival)])

        let merged = MainMapViewController.mergedPartnerships(my: [mine], festival: [festival])

        XCTAssertEqual(merged.map(\.storeName), ["A", "B"])
    }

    func test_같은_업체가_양쪽에_있으면_제휴_항목이_합쳐진다() {
        let mine = makeStore(name: "A", infos: [makeInfo(id: 1, periodType: .normal)])
        let festival = makeStore(name: "A", infos: [makeInfo(id: 2, periodType: .festival)])

        let merged = MainMapViewController.mergedPartnerships(my: [mine], festival: [festival])

        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(merged[0].partnershipIds, [1, 2])
    }

    func test_같은_항목_id는_중복으로_들어가지_않는다() {
        let mine = makeStore(name: "A", infos: [makeInfo(id: 1, periodType: .normal)])
        let festival = makeStore(name: "A", infos: [makeInfo(id: 1, periodType: .normal),
                                                    makeInfo(id: 3, periodType: .festival)])

        let merged = MainMapViewController.mergedPartnerships(my: [mine], festival: [festival])

        XCTAssertEqual(merged[0].partnershipIds, [1, 3])
    }

    func test_축제_목록이_비면_내_학과_제휴만_남는다() {
        let mine = makeStore(name: "A", infos: [makeInfo(id: 1, periodType: .normal)])

        let merged = MainMapViewController.mergedPartnerships(my: [mine], festival: [])

        XCTAssertEqual(merged.map(\.storeName), ["A"])
    }

    // MARK: - isFestivalStore (마커 색 결정)

    func test_축제_항목이_있으면_축제_업체로_판정한다() {
        let store = makeStore(name: "A", infos: [makeInfo(id: 1, periodType: .festival)])

        XCTAssertTrue(MainMapViewController.isFestivalStore(store))
    }

    func test_기존_제휴와_축제_제휴가_섞이면_축제_업체로_판정한다() {
        // 마커 색은 축제 우선 (한시적 혜택이 눈에 띄어야 함)
        let store = makeStore(name: "A", infos: [makeInfo(id: 1, periodType: .normal),
                                                 makeInfo(id: 2, periodType: .festival)])

        XCTAssertTrue(MainMapViewController.isFestivalStore(store))
    }

    func test_일반_제휴만_있으면_축제_업체가_아니다() {
        let store = makeStore(name: "A", infos: [makeInfo(id: 1, periodType: .normal)])

        XCTAssertFalse(MainMapViewController.isFestivalStore(store))
    }

    // MARK: - likeTarget (축제 제휴는 찜 불가)

    func test_축제_전용_업체는_찜_대상이_없다() {
        let store = makeStore(name: "A", infos: [makeInfo(id: 1, periodType: .festival)])

        XCTAssertNil(MainMapViewController.likeTarget(for: store))
    }

    func test_섞인_업체는_일반_제휴_항목만_찜_대상이_된다() {
        let store = makeStore(name: "A", infos: [makeInfo(id: 1, periodType: .normal),
                                                 makeInfo(id: 2, periodType: .festival)])

        XCTAssertEqual(MainMapViewController.likeTarget(for: store)?.partnershipIds, [1])
    }

    func test_일반_제휴_업체는_모든_항목이_찜_대상이다() {
        let store = makeStore(name: "A", infos: [makeInfo(id: 1, periodType: .normal),
                                                 makeInfo(id: 2, periodType: .normal)])

        XCTAssertEqual(MainMapViewController.likeTarget(for: store)?.partnershipIds, [1, 2])
    }

    // MARK: - filterPartnerships

    func test_전체_제휴_응답에서_축제_항목만_추린다() {
        let mixed = makeStore(name: "A", infos: [makeInfo(id: 1, periodType: .normal),
                                                 makeInfo(id: 2, periodType: .festival)])
        let normalOnly = makeStore(name: "B", infos: [makeInfo(id: 3, periodType: .normal)])

        let festivalOnly = MainMapViewController.filterPartnerships([mixed, normalOnly], by: .festival)

        XCTAssertEqual(festivalOnly.map(\.storeName), ["A"])
        XCTAssertEqual(festivalOnly[0].partnershipIds, [2])
    }
}
