//
//  EATSSUNetworkTests.swift
//  EATSSUNetwork
//
//  Created by JIWOONG CHOI on 2/17/25.
//

@testable import EATSSUNetwork
import Moya
import XCTest

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
                // 응답 상태 코드 확인
                debugPrint("응답 상태 코드: \(response.statusCode)")

                // 요청 URL 및 헤더 정보 출력
                if let urlResponse = response.response {
                    debugPrint("요청 URL: \(urlResponse.url?.absoluteString ?? "URL 없음")")
                    debugPrint("응답 헤더: \(urlResponse.allHeaderFields)")
                }

                // 응답 데이터 확인 (문자열로 변환)
                if let responseDataString = String(data: response.data, encoding: .utf8) {
                    debugPrint("응답 데이터: \(responseDataString)")
                } else {
                    debugPrint("응답 데이터: 변환 실패")
                }

                expectation.fulfill()
            case let .failure(error):
                XCTFail("요청 실패: \(error)")
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
                // 응답 상태 코드 및 데이터 유효성 체크
                XCTAssertEqual(response.statusCode, 200)
                XCTAssertFalse(response.data.isEmpty, "응답 데이터가 비어있습니다.")

                do {
                    let detailResponse = try JSONDecoder().decode(BaseResponse<PartnershipDetailResponse>.self, from: response.data)

                    // JSONPrettyPrinter를 활용한 디버깅 출력
                    if let prettyJSON = JSONPrettyPrinter.prettyPrintedJSONString(from: response.data) {
                        print("📌 Pretty JSON Response:\n\(prettyJSON)")
                    } else {
                        print("⚠️ JSON 포맷 변환 실패")
                    }

                } catch {
                    XCTFail("디코딩 또는 인코딩 실패: \(error)")
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
