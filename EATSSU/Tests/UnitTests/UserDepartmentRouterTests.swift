//
//  UserDepartmentRouterTests.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 2/23/25.
//

@testable import EATSSU_DEV
import XCTest

import EATSSUKit

import Moya
import RxSwift

final class UserDepartmentRouterTests: XCTestCase {
    var provider: MoyaProvider<UserDepartmentRouter>!
    var service: UserDepartmentService!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        // 실제 서버에 요청을 보내기 위해 stub 기능을 제거합니다.
        provider = MoyaProvider<UserDepartmentRouter>()
        service = UserDepartmentService(provider: provider)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        provider = nil
        service = nil
        disposeBag = nil
        super.tearDown()
    }

    /// 공통 응답 처리 및 디버깅을 위한 헬퍼 메서드
    private func handleResponse(_ response: Response, for endpoint: String) {
        // 상태 코드 및 헤더 정보 출력
        print("\n🔍 [\(endpoint)] Response Details:")
        print("📊 Status Code: \(response.statusCode)")

        // 요청 헤더 정보 출력
        if let request = response.request {
            print("\n📡 Request Headers:")
            request.allHTTPHeaderFields?.forEach { key, value in
                print("   \(key): \(value)")
            }
        }

        // 응답 데이터 파싱 및 출력
        if let prettyJSON = JSONPrettyPrinter.prettyPrintedJSONString(from: response.data) {
            print("\n📦 Response Data Structure:")
            print(prettyJSON)
        } else {
            print("⚠️ JSON 파싱 실패")
        }

        print("\n" + String(repeating: "-", count: 50) + "\n")
    }

    /// 부서 추가 API 테스트 (실제 서버 요청)
    func testAddDepartmentResponse() {
        let expectation = expectation(description: "addDepartment")
        let testDepartmentName = "컴퓨터학부"

        provider.request(.addDepartment(departmentName: testDepartmentName)) { result in
            switch result {
            case let .success(response):
                XCTAssertEqual(response.statusCode, 200, "응답 상태 코드가 200이 아닙니다.")
                XCTAssertFalse(response.data.isEmpty, "응답 데이터가 비어있습니다.")

                self.handleResponse(response, for: "AddDepartment")
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
                XCTAssertEqual(response.statusCode, 200, "응답 상태 코드가 200이 아닙니다.")
                XCTAssertFalse(response.data.isEmpty, "응답 데이터가 비어있습니다.")

                self.handleResponse(response, for: "ValidateDepartment")
                expectation.fulfill()

            case let .failure(error):
                XCTFail("validateDepartment 요청 실패: \(error)")
            }
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    /// UserDepartmentService를 사용한 학부 추가 테스트
    func testAddDepartmentWithService() {
        let expectation = expectation(description: "학부 추가 서비스")
        let testDepartmentName = "컴퓨터학부"

        service.addDepartment(departmentName: testDepartmentName)
            .subscribe(
                onSuccess: { response in
                    XCTAssertNotNil(response, "응답이 nil입니다.")
                    XCTAssertFalse(response.message.isEmpty, "응답 메시지가 비어있습니다.")
                    print("📌 Success Message: \(response.message)")
                    expectation.fulfill()
                },
                onFailure: { error in
                    XCTFail("부서 추가 실패: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    /// UserDepartmentService를 사용한 부서 검증 테스트
    func testValidateDepartmentWithService() {
        let expectation = expectation(description: "학부 검증 서비스")

        service.validateDepartment()
            .subscribe(
                onSuccess: { response in
                    XCTAssertNotNil(response, "응답이 nil입니다.")
                    expectation.fulfill()
                },
                onFailure: { error in
                    XCTFail("학부 검증 실패: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    /// 사용자 단과대의 제휴업체 API 테스트 (실제 서버 요청)
    func testGetUserPartnershipResponse() {
        let expectation = expectation(description: "getUserPartnership")

        provider.request(.getUserPartnership) { result in
            switch result {
            case let .success(response):
                XCTAssertEqual(response.statusCode, 200, "응답 상태 코드가 200이 아닙니다.")
                XCTAssertFalse(response.data.isEmpty, "응답 데이터가 비어있습니다.")

                self.handleResponse(response, for: "GetUserPartnership")
                expectation.fulfill()

            case let .failure(error):
                XCTFail("getUserPartnership 요청 실패: \(error)")
            }
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    /// UserDepartmentService를 사용한 제휴업체 조회 테스트
    func testGetUserPartnershipWithService() {
        let expectation = expectation(description: "제휴업체 조회 서비스")

        service.getUserPartnership()
            .subscribe(
                onSuccess: { response in
                    XCTAssertNotNil(response, "응답이 nil입니다.")
                    expectation.fulfill()
                },
                onFailure: { error in
                    XCTFail("제휴업체 조회 실패: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    /// 서비스 인스턴스 해제 시 에러 테스트
    func testServiceDeallocatedError() {
        let expectation = expectation(description: "서비스 해제 에러")
        var localService: UserDepartmentService? = UserDepartmentService(provider: provider)

        localService?.validateDepartment()
            .subscribe(
                onSuccess: { _ in
                    XCTFail("서비스가 해제되었는데 성공했습니다.")
                },
                onFailure: { error in
                    if let serviceError = error as? ServiceError {
                        XCTAssertEqual(serviceError, ServiceError.instanceDeallocated)
                        expectation.fulfill()
                    } else {
                        XCTFail("예상치 못한 에러 타입: \(error)")
                    }
                }
            )
            .disposed(by: disposeBag)

        localService = nil

        waitForExpectations(timeout: 5.0, handler: nil)
    }
}
