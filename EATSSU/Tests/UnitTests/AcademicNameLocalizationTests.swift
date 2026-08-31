//
//  AcademicNameLocalizationTests.swift
//  EATSSUUnitTests
//
//  Created by 황상환 on 8/31/26.
//

import XCTest

@testable import EATSSU_DEV

/// 단과대/학과명 번역 키 정규화와 언어별 표기 규칙 검증
final class AcademicNameLocalizationTests: XCTestCase {

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

    // MARK: - normalizedKey (서버 표기 차이 흡수)

    func test_아래아_구분자는_키에서_제거된다() {
        XCTAssertEqual(TextLiteral.Academic.normalizedKey("산업 ㆍ 정보시스템공학과"), "산업정보시스템공학과")
    }

    func test_가운뎃점과_공백은_키에서_제거된다() {
        XCTAssertEqual(TextLiteral.Academic.normalizedKey("정보통계·보험수리학과"), "정보통계보험수리학과")
    }

    func test_괄호는_키에서_제거된다() {
        XCTAssertEqual(TextLiteral.Academic.normalizedKey("전자정보공학부(전자공학전공)"), "전자정보공학부전자공학전공")
    }

    // MARK: - 언어별 표기

    func test_영어에서_등록된_학과는_영문으로_표기된다() {
        languageSandbox.set(.english)
        XCTAssertEqual(TextLiteral.Academic.college("인문대학"), "College of Humanities")
        XCTAssertEqual(TextLiteral.Academic.department("컴퓨터학부"), "Computer Science & Engineering")
    }

    func test_영어에서_서버_표기가_달라도_정규화로_매칭된다() {
        languageSandbox.set(.english)
        XCTAssertEqual(TextLiteral.Academic.department("정보통계·보험수리학과"), "Actuarial Science")
    }

    func test_등록되지_않은_이름은_원본을_그대로_반환한다() {
        languageSandbox.set(.english)
        XCTAssertEqual(TextLiteral.Academic.department("없는학과"), "없는학과")
    }

    func test_빈_문자열은_키를_노출하지_않고_빈_문자열을_반환한다() {
        languageSandbox.set(.english)
        XCTAssertEqual(TextLiteral.Academic.college(""), "")
    }

    func test_한국어는_ko_스트링스_표기를_사용한다() {
        languageSandbox.set(.korean)
        XCTAssertEqual(TextLiteral.Academic.college("인문대학"), "인문대학")
        // 서버가 아래아 표기를 줘도 ko 값(스프레드시트 표기)으로 통일된다
        XCTAssertEqual(TextLiteral.Academic.department("산업 ㆍ 정보시스템공학과"), "산업정보시스템공학과")
    }
}
