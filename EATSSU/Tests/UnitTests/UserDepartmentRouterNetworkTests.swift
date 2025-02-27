//
//  UserDepartmentRouterNetworkTests.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 2/23/25.
//

@testable import EATSSU_DEV
import XCTest

import EATSSUKit

import Moya

final class UserDepartmentRouterNetworkTests: XCTestCase {
    var provider: MoyaProvider<UserDepartmentRouter>!

    override func setUp() {
        super.setUp()
        // 실제 서버에 요청을 보내기 위해 stub 기능을 제거합니다.
        provider = MoyaProvider<UserDepartmentRouter>()
    }

    override func tearDown() {
        provider = nil
        super.tearDown()
    }

    /// 부서 추가 API 테스트 (실제 서버 요청)
    func testAddDepartmentResponse() {
        let expectation = expectation(description: "addDepartment")
        let testDepartmentName = "컴퓨터학부"

        provider.request(.addDepartment(departmentName: testDepartmentName)) { result in
            switch result {
            case let .success(response):
                // 상태 코드 검증
                XCTAssertEqual(response.statusCode, 200, "응답 상태 코드가 200이 아닙니다.")
                XCTAssertFalse(response.data.isEmpty, "응답 데이터가 비어있습니다.")

                // 토큰 값 출력
                if let request = response.request, let headers = request.allHTTPHeaderFields {
                    if let token = headers["Authorization"] {
                        print("🔑 Token: \(token)")
                    } else {
                        print("❌ Authorization 헤더가 없습니다.")
                    }
                }

                do {
                    let responseString = try response.mapString()
                    XCTAssertNotNil(responseString, "응답 문자열이 nil입니다.")

                    if let prettyJSON = JSONPrettyPrinter.prettyPrintedJSONString(from: response.data) {
                        print("📌 Pretty JSON Response:\n\(prettyJSON)")
                    } else {
                        print("⚠️ JSON 포맷 변환 실패")
                    }

                } catch {
                    XCTFail("응답 매핑 실패: \(error)")
                }

                expectation.fulfill()
            case let .failure(error):
                XCTFail("addDepartment 요청 실패: \(error)")
            }
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    /// 부서 이름 검증 API 테스트 (실제 서버 요청)
    func testValidateDepartmentResponse() {
        let expectation = expectation(description: "validateDepartment")

        provider.request(.validateDepartment) { result in
            switch result {
            case let .success(response):
                // 상태 코드 검증
                XCTAssertEqual(response.statusCode, 200, "응답 상태 코드가 200이 아닙니다.")
                XCTAssertFalse(response.data.isEmpty, "응답 데이터가 비어있습니다.")

                // 토큰 값 출력
                if let request = response.request, let headers = request.allHTTPHeaderFields {
                    if let token = headers["Authorization"] {
                        print("🔑 Token: \(token)")
                    } else {
                        print("❌ Authorization 헤더가 없습니다.")
                    }
                }

                do {
                    let responseString = try response.mapString()
                    XCTAssertNotNil(responseString, "응답 문자열이 nil입니다.")

                    if let prettyJSON = JSONPrettyPrinter.prettyPrintedJSONString(from: response.data) {
                        print("📌 Pretty JSON Response:\n\(prettyJSON)")
                    } else {
                        print("⚠️ JSON 포맷 변환 실패")
                    }

                } catch {
                    XCTFail("응답 매핑 실패: \(error)")
                }

                expectation.fulfill()
            case let .failure(error):
                XCTFail("validateDepartment 요청 실패: \(error)")
            }
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    /// UserDepartmentService를 사용한 부서 추가 테스트
    func testAddDepartmentWithService() {
        let expectation = expectation(description: "부서 추가 서비스")
        let service = UserDepartmentService()
        let testDepartmentName = "컴퓨터학부"
        
        service.addDepartment(departmentName: testDepartmentName) { result in
            switch result {
            case .success(let message):
                XCTAssertFalse(message.isEmpty, "응답 메시지가 비어있습니다.")
                print("📌 Success Message: \(message)")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("부서 추가 실패: \(error.localizedDescription)")
            }
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    /// UserDepartmentService를 사용한 부서 검증 테스트
    func testValidateDepartmentWithService() {
        let expectation = expectation(description: "부서 검증 서비스")
        let service = UserDepartmentService()
        
        service.validateDepartment { result in
            switch result {
            case .success(let message):
                XCTAssertFalse(message.isEmpty, "응답 메시지가 비어있습니다.")
                print("📌 Validation Message: \(message)")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("부서 검증 실패: \(error.localizedDescription)")
            }
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    } 
}
