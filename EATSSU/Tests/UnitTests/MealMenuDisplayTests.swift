//
//  MealMenuDisplayTests.swift
//  EATSSUUnitTests
//
//  Created by 황상환 on 8/31/26.
//

import XCTest

@testable import EATSSU_DEV

/// 변동식단 대표메뉴 표시 규칙과 언어 파라미터 검증
final class MealMenuDisplayTests: XCTestCase {

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

    private func makeMeal(_ menus: [(name: String, isMain: Bool?)]) -> ChangeMenuTableResponse {
        ChangeMenuTableResponse(
            mealId: 1,
            price: 5000,
            rating: nil,
            briefMenus: menus.enumerated().map { BriefMenus(menuId: $0.offset, name: $0.element.name, isMain: $0.element.isMain) }
        )
    }

    func test_영어에서는_대표메뉴만_표시한다() {
        languageSandbox.set(.english)
        let meal = makeMeal([("Pork Cutlet", true), ("김치", false), ("밥", false)])
        XCTAssertEqual(meal.displayMenus.map(\.name), ["Pork Cutlet"])
    }

    func test_영어라도_대표메뉴가_없으면_전체를_표시한다() {
        // 대표메뉴 데이터가 아직 없는 식단은 전부 isMain=false/nil로 내려온다 (서버 안내)
        languageSandbox.set(.english)
        let meal = makeMeal([("김치", false), ("밥", nil)])
        XCTAssertEqual(meal.displayMenus.count, 2)
    }

    func test_한국어에서는_대표메뉴_여부와_무관하게_전체를_표시한다() {
        languageSandbox.set(.korean)
        let meal = makeMeal([("돈까스", true), ("김치", false)])
        XCTAssertEqual(meal.displayMenus.count, 2)
    }

    func test_변동식단_언어_파라미터는_영어만_전달한다() {
        languageSandbox.set(.english)
        XCTAssertEqual(ChangeMenuTableResponse.mealLanguageParameter, "EN")

        languageSandbox.set(.japanese)
        XCTAssertNil(ChangeMenuTableResponse.mealLanguageParameter)

        languageSandbox.set(.korean)
        XCTAssertNil(ChangeMenuTableResponse.mealLanguageParameter)
    }

    func test_고정메뉴_언어_파라미터는_한국어_외_전부_전달한다() {
        languageSandbox.set(.japanese)
        XCTAssertEqual(ChangeMenuTableResponse.fixedMenuLanguageParameter, "JA")

        languageSandbox.set(.korean)
        XCTAssertNil(ChangeMenuTableResponse.fixedMenuLanguageParameter)
    }
}
