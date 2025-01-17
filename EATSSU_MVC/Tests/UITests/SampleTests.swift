//
//  SampleTests.swift
//  UITests
//
//  Created by Jiwoong CHOI on 9/14/24.
//

import XCTest

final class SampleTests: XCTestCase {
    @MainActor
    override func setUpWithError() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    override func tearDownWithError() throws {}

    /// 스크린샷 촬영 자동화 스크립트 입니다.
    @MainActor
    func testTakingSnapShot() {
        snapshot("01_LoginScreen")
    }
}
