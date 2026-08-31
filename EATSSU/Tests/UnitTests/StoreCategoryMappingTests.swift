//
//  StoreCategoryMappingTests.swift
//  EATSSUUnitTests
//
//  Created by 황상환 on 8/31/26.
//

import XCTest

@testable import EATSSU_DEV

/// 식당/업종 enum과 서버 문자열 매핑 검증
final class StoreCategoryMappingTests: XCTestCase {

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

    // MARK: - Restaurant

    func test_식당_rawValue는_strings_키로_사용된다() {
        XCTAssertEqual(Restaurant.dodamRestaurant.rawValue, "dodamRestaurant")
        XCTAssertEqual(Restaurant.snackCorner.rawValue, "snackCorner")
    }

    func test_식당_서버_식별자_매핑() {
        XCTAssertEqual(Restaurant.studentRestaurant.identifier, "HAKSIK")
        XCTAssertEqual(Restaurant.snackCorner.identifier, "SNACK_CORNER")
    }

    func test_한국어_표시_이름으로_식당을_역조회한다() {
        languageSandbox.set(.korean)
        XCTAssertEqual(Restaurant(title: "도담 식당"), .dodamRestaurant)
        XCTAssertNil(Restaurant(title: "없는 식당"))
    }

    func test_RemoteConfig_매칭용_한국어_이름() {
        XCTAssertEqual(Restaurant.facultyRestaurant.koreanName, "FACULTY (교직원 전용)")
    }

    // MARK: - GoodPriceCategory

    func test_서버_카테고리_문자열_역매핑() {
        XCTAssertEqual(GoodPriceCategory(serverValue: "BAKERY"), .bakery)
        XCTAssertNil(GoodPriceCategory(serverValue: "UNKNOWN"))
    }

    func test_전체는_서버_파라미터를_보내지_않는다() {
        XCTAssertNil(GoodPriceCategory.all.serverValue)
    }

    func test_전체를_제외한_카테고리는_서버_값과_왕복된다() {
        for category in GoodPriceCategory.allCases where category != .all {
            let serverValue = try! XCTUnwrap(category.serverValue)
            XCTAssertEqual(GoodPriceCategory(serverValue: serverValue), category)
        }
    }

    // MARK: - PartnershipFilter

    func test_제휴_필터의_서버_업종_값() {
        XCTAssertEqual(PartnershipFilter.restaurant.restaurantType, "RESTAURANT")
        XCTAssertEqual(PartnershipFilter.cafe.restaurantType, "CAFE")
        XCTAssertEqual(PartnershipFilter.pub.restaurantType, "PUB")
        XCTAssertNil(PartnershipFilter.all.restaurantType)
        XCTAssertNil(PartnershipFilter.festival.restaurantType)
    }
}
