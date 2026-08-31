//
//  PartnershipLikeLogicTests.swift
//  EATSSUUnitTests
//
//  Created by 황상환 on 8/31/26.
//

import XCTest

@testable import EATSSU_DEV

/// 제휴 찜 순수 로직 검증 (토글 대상 계산, 찜 목록 해석, 최근 추가순 정렬)
final class PartnershipLikeLogicTests: XCTestCase {

    // MARK: - Helpers

    private func makeInfo(id: Int, isLiked: Bool = false) -> PartnershipInfoDTO {
        PartnershipInfoDTO(
            id: id,
            collegeName: "IT대학",
            departmentName: nil,
            likeCount: 0,
            isLiked: isLiked,
            description: "제휴 내용",
            startDate: "2026-09-01",
            endDate: "2026-12-31",
            periodType: .normal
        )
    }

    private func makeStore(name: String, infos: [PartnershipInfoDTO]) -> PartnershipDTO {
        PartnershipDTO(
            storeName: name,
            longitude: 126.95,
            latitude: 37.49,
            restaurantType: "RESTAURANT",
            naverMapUrl: nil,
            kakaoMapUrl: nil,
            partnershipInfos: infos
        )
    }

    // MARK: - toggleTargets (토글 API라 같은 상태를 다시 호출하면 뒤집힌다)

    func test_찜_추가시_이미_찜된_항목은_토글하지_않는다() {
        let store = makeStore(name: "A", infos: [makeInfo(id: 1), makeInfo(id: 2), makeInfo(id: 3)])
        let alreadyLiked: Set<Int> = [2]

        let targets = PartnershipLikeManager.toggleTargets(in: store, toBe: true) { alreadyLiked.contains($0.id) }

        XCTAssertEqual(targets, [1, 3])
    }

    func test_찜_해제시_찜된_항목만_토글한다() {
        let store = makeStore(name: "A", infos: [makeInfo(id: 1), makeInfo(id: 2)])
        let alreadyLiked: Set<Int> = [1]

        let targets = PartnershipLikeManager.toggleTargets(in: store, toBe: false) { alreadyLiked.contains($0.id) }

        XCTAssertEqual(targets, [1])
    }

    func test_상태가_모두_목표와_같으면_토글_대상이_없다() {
        let store = makeStore(name: "A", infos: [makeInfo(id: 1), makeInfo(id: 2)])

        let targets = PartnershipLikeManager.toggleTargets(in: store, toBe: true) { _ in true }

        XCTAssertTrue(targets.isEmpty)
    }

    // MARK: - likedIds (찜 목록 응답 해석)

    func test_isLiked_플래그가_있으면_해당_항목만_찜으로_해석한다() {
        let store = makeStore(name: "A", infos: [makeInfo(id: 1, isLiked: true), makeInfo(id: 2, isLiked: false)])

        XCTAssertEqual(PartnershipLikeManager.likedIds(in: store), [1])
    }

    func test_플래그가_하나도_없으면_전체를_찜으로_간주한다() {
        // 구버전 응답 호환: 찜 목록에 온 업체인데 플래그가 없으면 전부 찜으로 본다
        let store = makeStore(name: "A", infos: [makeInfo(id: 1), makeInfo(id: 2)])

        XCTAssertEqual(PartnershipLikeManager.likedIds(in: store), [1, 2])
    }

    // MARK: - sortedByRecent (최근 추가순)

    func test_찜한_시각이_최근인_업체가_앞에_온다() {
        let a = makeStore(name: "A", infos: [makeInfo(id: 1)])
        let b = makeStore(name: "B", infos: [makeInfo(id: 2)])
        let likedAt = [a.storeKey: 100.0, b.storeKey: 200.0]

        let sorted = PartnershipLikeManager.sortedByRecent([a, b], likedAt: likedAt)

        XCTAssertEqual(sorted.map(\.storeName), ["B", "A"])
    }

    func test_시각_기록이_없는_업체는_서버_순서대로_뒤에_온다() {
        let recorded = makeStore(name: "기록됨", infos: [makeInfo(id: 1)])
        let unknown1 = makeStore(name: "미기록1", infos: [makeInfo(id: 2)])
        let unknown2 = makeStore(name: "미기록2", infos: [makeInfo(id: 3)])
        let likedAt = [recorded.storeKey: 100.0]

        let sorted = PartnershipLikeManager.sortedByRecent([unknown1, recorded, unknown2], likedAt: likedAt)

        XCTAssertEqual(sorted.map(\.storeName), ["기록됨", "미기록1", "미기록2"])
    }

    // MARK: - storeKey

    func test_업체_키는_이름과_좌표로_구성된다() {
        let store = makeStore(name: "현선이네", infos: [makeInfo(id: 1)])

        XCTAssertEqual(store.storeKey, "현선이네|37.49|126.95")
        XCTAssertEqual(store.partnershipIds, [1])
    }
}
