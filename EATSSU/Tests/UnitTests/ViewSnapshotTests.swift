//
//  ViewSnapshotTests.swift
//  EATSSUUnitTests
//
//  Created by 황상환 on 8/31/26.
//

import SnapshotTesting
import XCTest

@testable import EATSSU_DEV

/// 신규 화면 컴포넌트의 렌더링 회귀 방지 스냅샷
///
/// - 참조 이미지는 `__Snapshots__/`에 저장되며, 의도한 UI 변경 시 갱신해 함께 커밋한다.
/// - 렌더링 일치를 위해 displayScale 2로 고정하고, CI도 같은 기기 모델(iPhone 17 Pro)을 사용한다.
/// - 네트워크 없이 그릴 수 있는 순수 데이터 뷰만 대상으로 한다.
final class ViewSnapshotTests: XCTestCase {

    private var languageSandbox: AppLanguageSandbox!

    override func setUp() {
        super.setUp()
        languageSandbox = AppLanguageSandbox()
    }

    override func tearDown() {
        languageSandbox.restore()
        languageSandbox = nil
        super.tearDown()
    }

    // MARK: - Helpers

    /// 고정 크기·고정 스케일로 뷰 스냅샷 비교. height가 nil이면 오토레이아웃 콘텐츠 높이로 self-sizing
    private func assertViewSnapshot(
        _ view: UIView,
        width: CGFloat = 390,
        height: CGFloat? = nil,
        named name: String,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line
    ) {
        let resolvedHeight = height ?? view.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        view.frame = CGRect(origin: .zero, size: CGSize(width: width, height: resolvedHeight))
        view.layoutIfNeeded()
        assertSnapshot(
            of: view,
            as: .image(traits: UITraitCollection(displayScale: 2)),
            named: name,
            file: file,
            testName: testName,
            line: line
        )
    }

    private func makeStore() -> PartnershipDTO {
        PartnershipDTO(
            storeName: "현선이네",
            longitude: 126.9572,
            latitude: 37.4963,
            restaurantType: "RESTAURANT",
            naverMapUrl: nil,
            kakaoMapUrl: nil,
            partnershipInfos: [
                PartnershipInfoDTO(
                    id: 1,
                    collegeName: "IT대학",
                    departmentName: nil,
                    likeCount: 0,
                    isLiked: false,
                    description: "학생증 인증하면 음료수 1개 증정 및 블라블라블라블라",
                    startDate: "2026-09-03",
                    endDate: "2026-12-18",
                    periodType: .normal
                )
            ]
        )
    }

    // MARK: - 찜 목록 셀

    func test_찜목록_셀_기본() {
        languageSandbox.set(.korean)
        let cell = LikedPartnershipCell(style: .default, reuseIdentifier: nil)
        cell.configure(store: makeStore(), mode: .normal)
        assertViewSnapshot(cell, height: 77, named: "ko")
    }

    func test_찜목록_셀_편집모드_선택됨() {
        languageSandbox.set(.korean)
        let cell = LikedPartnershipCell(style: .default, reuseIdentifier: nil)
        cell.configure(store: makeStore(), mode: .editing(isSelected: true))
        assertViewSnapshot(cell, height: 77, named: "ko")
    }

    func test_찜목록_셀_영어() {
        languageSandbox.set(.english)
        let cell = LikedPartnershipCell(style: .default, reuseIdentifier: nil)
        cell.configure(store: makeStore(), mode: .normal)
        assertViewSnapshot(cell, height: 77, named: "en")
    }

    // MARK: - 빈 화면

    func test_빈화면_찜없음() {
        languageSandbox.set(.korean)
        let view = EmptyStateView()
        view.configure(title: TextLiteral.Like.emptyTitle, subtitle: TextLiteral.Like.emptySubtitle)
        assertViewSnapshot(view, height: 500, named: "ko")
    }

    // MARK: - 식당 정보 시트 뷰

    /// Remote Config·네트워크 이미지를 배제한 결정적 식당 정보 데이터 (strings 다국어 값만 사용)
    private func restaurantInfoFixture() -> RestaurantInfoData {
        let saved = RestaurantInfoData.restaurantInfoData
        RestaurantInfoData.restaurantInfoData = []
        defer { RestaurantInfoData.restaurantInfoData = saved }
        let base = RestaurantInfoData.localized(for: .studentRestaurant)
        return RestaurantInfoData(
            name: base.name, location: base.location, time: base.time, etc: base.etc, image: ""
        )
    }

    func test_식당정보_한국어() {
        languageSandbox.set(.korean)
        let view = RestaurantInfoView()
        view.backgroundColor = .white // 시트 배경과 동일 (뷰 단독은 투명이라 스냅샷 가독성 확보)
        view.bind(data: restaurantInfoFixture())
        assertViewSnapshot(view, named: "ko")
    }

    func test_식당정보_영어() {
        languageSandbox.set(.english)
        let view = RestaurantInfoView()
        view.backgroundColor = .white
        view.bind(data: restaurantInfoFixture())
        assertViewSnapshot(view, named: "en")
    }

    // MARK: - 지도 앱 버튼 바

    func test_지도앱_버튼바() {
        languageSandbox.set(.korean)
        assertViewSnapshot(MapAppButtonBar(), height: 56, named: "ko")
    }
}
