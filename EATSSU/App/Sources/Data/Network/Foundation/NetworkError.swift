//
//  NetworkError.swift
//  EATSSU
//
//  Created by 황상환 on 10/17/25.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    /// 응답은 성공했으나, result 값이 nil일 때 (e.g., Bool 타입 응답)
    case noData(code: Int)

    /// isSuccess가 false일 때 (서버에서 정의한 에러)
    case serverError(code: Int, message: String)

    /// 응답 모델 디코딩에 실패했을 때
    case decodingError(Error)

    /// Moya에서 발생한 근본적인 에러 (e.g., 인터넷 연결 끊김)
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .noData:
            return "응답 데이터가 없습니다."
        case .serverError(_, let message):
            return message
        case .decodingError:
            return "데이터를 변환하는데 실패했습니다."
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}
