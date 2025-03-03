//
//  PartnershipRouterTests.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 2/17/25.
//

@testable import EATSSU_DEV

import EATSSUKit

import Moya
import RxBlocking
import RxSwift
import RxTest
import XCTest

final class PartnershipRouterTests: XCTestCase {
    var provider: MoyaProvider<PartnershipRouter>!
    var service: PartnershipService!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        // 실제 서버에 요청을 보내기 위해 stub 기능을 제거합니다.
        provider = MoyaProvider<PartnershipRouter>()
        service = PartnershipService(provider: provider)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        provider = nil
        service = nil
        disposeBag = nil
        super.tearDown()
    }

    private func handleResponse(_ response: Response, for endpoint: String) {
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

    // MARK: - Router Tests

    /// 전체 제휴 목록 조회 API 테스트 (실제 서버 요청)
    func testFetchAllPartnershipsResponse() {
        let expectation = expectation(description: "fetchAllPartnerships")

        provider.request(.fetchAllPartnerships) { result in
            switch result {
            case let .success(response):
                XCTAssertEqual(response.statusCode, 200, "응답 상태 코드가 200이 아닙니다.")
                XCTAssertFalse(response.data.isEmpty, "응답 데이터가 비어있습니다.")

                do {
                    let partnershipsResponse = try JSONDecoder().decode(BaseResponse<[PartnershipResponse]>.self, from: response.data)
                    XCTAssertNotNil(partnershipsResponse, "디코딩된 데이터가 nil입니다.")
                    self.handleResponse(response, for: "FetchAllPartnerships")
                } catch {
                    XCTFail("디코딩 실패: \(error)")
                }

                expectation.fulfill()
            case let .failure(error):
                XCTFail("fetchAllPartnerships 요청 실패: \(error)")
            }
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    /// 특정 제휴 상세 조회 API 테스트 (실제 서버 요청)
    func testFetchPartnershipDetailResponse() {
        let partnershipId = 2
        let expectation = expectation(description: "fetchPartnershipDetail")

        provider.request(.fetchPartnershipDetail(partnershipId: partnershipId)) { result in
            switch result {
            case let .success(response):
                XCTAssertEqual(response.statusCode, 200)
                XCTAssertFalse(response.data.isEmpty, "응답 데이터가 비어있습니다.")

                do {
                    let detailResponse = try JSONDecoder().decode(BaseResponse<PartnershipDetailResponse>.self, from: response.data)
                    XCTAssertNotNil(detailResponse, "디코딩된 데이터가 nil입니다.")
                    self.handleResponse(response, for: "FetchPartnershipDetail")
                } catch {
                    XCTFail("디코딩 실패: \(error)")
                }

                expectation.fulfill()
            case let .failure(error):
                XCTFail("fetchPartnershipDetail 실패: \(error)")
            }
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    // MARK: - Service Tests

    /// 전체 제휴 목록 조회 Service 테스트
    func testFetchAllPartnershipsService() {
        let expectation = expectation(description: "전체 제휴 목록 조회 Service")

        service.fetchAllPartnerships()
            .subscribe(
                onSuccess: { response in
                    // JSON 응답 출력
                    print("\n🔍 [FetchAllPartnerships Service] Response Details:")
                    if let jsonData = try? JSONEncoder().encode(response),
                       let prettyJSON = JSONPrettyPrinter.prettyPrintedJSONString(from: jsonData)
                    {
                        print("\n📦 Response Data Structure:")
                        print(prettyJSON)
                    } else {
                        print("⚠️ JSON 변환 실패")
                    }
                    print("\n" + String(repeating: "-", count: 50) + "\n")

                    expectation.fulfill()
                },
                onFailure: { error in
                    XCTFail("Service 호출 실패: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 10.0)
    }

    /// 제휴 상세 정보 조회 Service 테스트
    func testFetchPartnershipDetailService() {
        let expectation = expectation(description: "제휴 상세 정보 조회 Service")
        let partnershipId = 2

        service.fetchPartnershipDetail(partnershipId: partnershipId)
            .subscribe(
                onSuccess: { response in
                    // JSON 응답 출력
                    print("\n🔍 [FetchPartnershipDetail Service] Response Details:")
                    if let jsonData = try? JSONEncoder().encode(response),
                       let prettyJSON = JSONPrettyPrinter.prettyPrintedJSONString(from: jsonData)
                    {
                        print("\n📦 Response Data Structure:")
                        print(prettyJSON)
                    } else {
                        print("⚠️ JSON 변환 실패")
                    }
                    print("\n" + String(repeating: "-", count: 50) + "\n")

                    expectation.fulfill()
                },
                onFailure: { error in
                    XCTFail("Service 호출 실패: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 10.0)
    }
}
