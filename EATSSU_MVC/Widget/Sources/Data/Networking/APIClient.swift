//
//  APIClient.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 12/31/24.
//

import Foundation

import Moya
import RxMoya
import RxSwift

class APIClient {
    private let provider = MoyaProvider<HomeRouter>(plugins: [NetworkLoggerPlugin()])

    func fetchChangeMenuTableResponse(date: String, restaurant: String, time: String) -> Single<BaseResponse<[ChangeMenuTableResponse]>> {
        return provider.rx.request(.getChangeMenuTableResponse(date: date, restaurant: restaurant, time: time))
            .filterSuccessfulStatusCodes()
            .map(BaseResponse<[ChangeMenuTableResponse]>.self)
    }
}
