//
//  MenuFavoriteRouter.swift
//  EATSSU
//
//  Created by 황상환 on 10/6/26.
//

import Foundation

import Moya

/// 메뉴 찜 API (모두 로그인 필요)
enum MenuFavoriteRouter {
    /// 찜할 메뉴 검색. 앞뒤 공백 제거 후 2글자 미만이면 서버가 400을 반환한다
    case search(keyword: String)
    /// 찜한 메뉴 목록 (최근 찜한 순)
    case getFavorites
    /// 찜하기. 이미 찜한 메뉴여도 성공
    case add(menuId: Int)
    /// 찜 취소. 찜하지 않은 메뉴여도 성공
    case remove(menuId: Int)
}

extension MenuFavoriteRouter: TargetType {
    var baseURL: URL {
        URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .search:
            "/menu-favorites/search"
        case .getFavorites:
            "/menu-favorites"
        case let .add(menuId), let .remove(menuId):
            "/menu-favorites/\(menuId)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .search, .getFavorites:
            .get
        case .add:
            .post
        case .remove:
            .delete
        }
    }

    var task: Moya.Task {
        switch self {
        case let .search(keyword):
            .requestParameters(parameters: ["keyword": keyword], encoding: URLEncoding.queryString)
        case .getFavorites, .add, .remove:
            .requestPlain
        }
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }

    var validationType: ValidationType {
        .successCodes
    }
}
