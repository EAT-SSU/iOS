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
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            var output = ""
            prettyPrintJSON(jsonObject, to: &output)
            return output
        } catch {
            debugPrint("JSON 파싱 실패: \(error)")
            return nil
        }
    }

    /// JSON 객체를 계층적으로 출력하는 메서드
    ///
    /// - Parameters:
    ///   - object: 출력할 JSON 객체
    ///   - output: 출력 문자열을 저장할 String 버퍼
    ///   - indent: 들여쓰기 레벨 (기본값: 0)
    private static func prettyPrintJSON(_ object: Any, to output: inout String, indent: Int = 0) {
        let indentation = String(repeating: " ", count: indent)

        switch object {
        case let dictionary as [String: Any]:
            for (key, value) in dictionary {
                if let array = value as? [Any] {
                    output += "\(indentation)📎 \(key): [\n"
                    for item in array {
                        prettyPrintJSON(item, to: &output, indent: indent + 3)
                    }
                    output += "\(indentation)]\n"
                } else if value is [String: Any] {
                    output += "\(indentation)🔸 \(key): {\n"
                    prettyPrintJSON(value, to: &output, indent: indent + 3)
                    output += "\(indentation)}\n"
                } else {
                    output += "\(indentation)🔹 \(key): \(value)\n"
                }
            }
        case let array as [Any]:
            for item in array {
                prettyPrintJSON(item, to: &output, indent: indent)
            }
        default:
            output += "\(indentation)📍 \(object)\n"
        }
    }
}
