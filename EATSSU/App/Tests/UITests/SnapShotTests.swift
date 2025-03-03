//
//  SnapShotTests.swift
//  UITests
//
//  Created by Jiwoong CHOI on 9/14/24.
//

import XCTest

final class SnapShotTests: XCTestCase {
    var app: XCUIApplication!

    @MainActor
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        setupSnapshot(app) // fastlane snapshot 초기화
        app.launch()
    }

    override func tearDownWithError() throws {}

    /// 탭바의 각 화면에서 스크린샷을 촬영하는 테스트 예시입니다.
    ///  로그인이 되어있어야하고, 학과 역시 입력되어 있어야 합니다.
    @MainActor
    func testTabBarScreenshots() {
        // 1. "학식" 탭 선택 및 스크린샷 촬영
        let mealButton = app.tabBars.buttons["학식"]
        mealButton.tap()
        let mealPredicate = NSPredicate(format: "isSelected == true")
        expectation(for: mealPredicate, evaluatedWith: mealButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        snapshot("01_Restaurant")

        // 2. "지도" 탭 선택 및 스크린샷 촬영
        let mapButton = app.tabBars.buttons["지도"]
        mapButton.tap()
        let mapPredicate = NSPredicate(format: "isSelected == true")
        expectation(for: mapPredicate, evaluatedWith: mapButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        snapshot("02_Map")

        // 3. "마이" 탭 선택 및 스크린샷 촬영
        let myButton = app.tabBars.buttons["마이"]
        myButton.tap()
        let myPredicate = NSPredicate(format: "isSelected == true")
        expectation(for: myPredicate, evaluatedWith: myButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        snapshot("03_MyPage")
    }
}
