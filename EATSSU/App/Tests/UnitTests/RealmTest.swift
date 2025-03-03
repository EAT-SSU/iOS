//
//  RealmTest.swift
//  EATSSUUnitTests
//
//  Created by JIWOONG CHOI on 2/24/25.
//

@testable import EATSSU_DEV

import XCTest

final class RealmTest: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCheckingTokenValue() throws {
        // 주의 : 디바이스에 로그인이 되어있어야 확인가능
        print(RealmService.shared.getToken())
    }
}
