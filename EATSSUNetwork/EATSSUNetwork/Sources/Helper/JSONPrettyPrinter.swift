//
//  JSONPrettyPrinter.swift
//  EATSSUNetwork
//
//  Created by JIWOONG CHOI on 2/17/25.
//

import Foundation

/// JSON 데이터를 읽기 쉬운 문자열 형식으로 변환해주는 유틸리티 클래스
public enum JSONPrettyPrinter {
    /// JSON 데이터를 prettyPrint 된 문자열로 변환하는 함수
    ///
    /// - Parameter data: JSON 형식의 Data
    /// - Returns: 읽기 쉬운 JSON 문자열, 변환에 실패할 경우 nil 반환
    public static func prettyPrintedJSONString(from data: Data) -> String? {
        do {
            // JSON 객체로 변환
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            // prettyPrinted 옵션을 사용하여 Data로 변환
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
            // 문자열로 변환 후 반환
            return String(data: prettyData, encoding: .utf8)
        } catch {
            debugPrint("JSON 파싱 실패: \(error)")
            return nil
        }
    }
}
