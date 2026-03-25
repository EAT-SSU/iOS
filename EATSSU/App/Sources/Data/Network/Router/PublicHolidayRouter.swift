//
//  PublicHolidayRouter.swift
//  EATSSU
//
//  Created by jeongminji on 3/25/26.
//

import Foundation
import Moya

enum PublicHolidayRouter {
    case getPublicHolidays(serviceKey: String, year: Int, month: Int)
}

extension PublicHolidayRouter: TargetType {
    var baseURL: URL {
        URL(string: "https://apis.data.go.kr")!
    }
    
    var path: String {
        switch self {
        case .getPublicHolidays:
            "/B090041/openapi/service/SpcdeInfoService/getRestDeInfo"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getPublicHolidays:
                .get
        }
    }
    
    var task: Task {
        switch self {
        case let .getPublicHolidays(serviceKey, year, month):
            return .requestParameters(
                parameters: [
                    "ServiceKey": serviceKey,
                    "solYear": String(year),
                    "solMonth": String(format: "%02d", month),
                    "numOfRows": 50,
                    "pageNo": 1,
                    "_type": "json"
                ],
                encoding: URLEncoding.queryString
            )
        }
    }
    
    var headers: [String: String]? {
        ["Content-type": "application/json"]
    }
    
    var sampleData: Data {
        Data()
    }
}
