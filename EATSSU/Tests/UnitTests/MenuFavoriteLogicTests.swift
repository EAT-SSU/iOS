//
//  MenuFavoriteLogicTests.swift
//  EATSSUUnitTests
//
//  Created by 황상환 on 10/6/26.
//

import XCTest

@testable import EATSSU_DEV

/// 메뉴 찜 검색 결과 정렬 검증 (기능 명세: 검색어로 시작하는 메뉴 우선, 나머지는 가나다순)
final class MenuFavoriteLogicTests: XCTestCase {

    // MARK: - Helpers

    private func makeMenu(_ id: Int, _ name: String, restaurant: String = "HAKSIK") -> MenuSearchDTO {
        MenuSearchDTO(menuId: id, menuName: name, restaurant: restaurant, isFavorite: false)
    }

    private func sortedNames(_ names: [String], keyword: String) -> [String] {
        let menus = names.enumerated().map { makeMenu($0.offset, $0.element) }
        return MenuFavoriteManager.sortedForDisplay(menus, keyword: keyword).map(\.menuName)
    }

    // MARK: - Tests

    func test_검색어로_시작하는_메뉴가_먼저_나오고_나머지는_가나다순() {
        let result = sortedNames(["포기김치", "뚝배기목살김치찌개", "배추김치", "김치닭볶음탕"], keyword: "김치")
        XCTAssertEqual(result, ["김치닭볶음탕", "뚝배기목살김치찌개", "배추김치", "포기김치"])
    }

    func test_검색어로_시작하는_메뉴끼리도_가나다순() {
        let result = sortedNames(["김치찌개", "김치", "김치볶음밥"], keyword: "김치")
        XCTAssertEqual(result, ["김치", "김치볶음밥", "김치찌개"])
    }

    func test_영문은_대소문자를_구분하지_않고_앞에_오는지_판단() {
        let result = sortedNames(["Grilled Meat", "Meatball", "meat pie"], keyword: "me")
        XCTAssertEqual(result.prefix(2).sorted(), ["Meatball", "meat pie"].sorted())
        XCTAssertEqual(result.last, "Grilled Meat")
    }

    func test_검색어_앞뒤_공백은_무시() {
        let result = sortedNames(["배추김치", "김치전"], keyword: "  김치 ")
        XCTAssertEqual(result, ["김치전", "배추김치"])
    }

    func test_같은_메뉴명이면_서버_순서_유지() {
        let menus = [
            makeMenu(1, "김치찌개", restaurant: "DODAM"),
            makeMenu(2, "김치찌개", restaurant: "HAKSIK"),
            makeMenu(3, "김치볶음밥", restaurant: "DORMITORY")
        ]
        let result = MenuFavoriteManager.sortedForDisplay(menus, keyword: "김치").map(\.menuId)
        XCTAssertEqual(result, [3, 1, 2])
    }
}
