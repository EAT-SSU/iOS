//
//  PartnershipRouterNetworkTests.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 2/17/25.
//

@testable import EATSSU_DEV

import EATSSUKit

import XCTest

import Moya

final class PartnershipRouterNetworkTests: XCTestCase {
    var provider: MoyaProvider<PartnershipRouter>!

    override func setUp() {
        super.setUp()
        // 실제 서버에 요청을 보내기 위해 stub 기능을 제거합니다.
        provider = MoyaProvider<PartnershipRouter>()
    }

    /// 전체 제휴 목록 조회 API 테스트 (실제 서버 요청)
    func testFetchAllPartnershipsResponse() {
        let expectation = expectation(description: "fetchAllPartnerships")

        provider.request(.fetchAllPartnerships) { result in
            switch result {
            case let .success(response):
                XCTAssertEqual(response.statusCode, 200, "응답 상태 코드가 200이 아닙니다.")
                XCTAssertFalse(response.data.isEmpty, "응답 데이터가 비어있습니다.")

                do {
                    // 응답 데이터를 DTO로 변환하여 검증

                    let partnershipsResponse = try JSONDecoder().decode(BaseResponse<[PartnershipResponse]>.self, from: response.data)

                    XCTAssertNotNil(partnershipsResponse, "디코딩된 데이터가 nil입니다.")

                    // JSON을 보기 좋게 출력
                    if let prettyJSON = JSONPrettyPrinter.prettyPrintedJSONString(from: response.data) {
                        print("📌 Pretty JSON Response:\n\(prettyJSON)")
                    } else {
                        print("⚠️ JSON 포맷 변환 실패")
                    }

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

                    // DTO 필드 검증
                    XCTAssertNotNil(detailResponse, "디코딩된 데이터가 nil입니다.")

                    // JSONPrettyPrinter를 활용한 디버깅 출력
                    if let prettyJSON = JSONPrettyPrinter.prettyPrintedJSONString(from: response.data) {
                        print("📌 Pretty JSON Response:\n\(prettyJSON)")
                    } else {
                        print("⚠️ JSON 포맷 변환 실패")
                    }

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

    /// 제휴 찜 등록/취소 API 테스트 (실제 서버 요청)
    func testTogglePartnershipFavoriteResponse() {
        let partnershipId = 456
        let expectation = expectation(description: "togglePartnershipFavorite")

        provider.request(.togglePartnershipFavorite(partnershipId: partnershipId)) { result in
            switch result {
            case let .success(response):
                XCTAssertEqual(response.statusCode, 200)
                XCTAssertFalse(response.data.isEmpty, "응답 데이터가 비어있습니다.")
                expectation.fulfill()
            case let .failure(error):
                XCTFail("togglePartnershipFavorite 실패: \(error)")
            }
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }
}
