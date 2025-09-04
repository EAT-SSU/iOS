//
//  PartnershipRouter.swift
//  EATSSU
//
//  Created by 황상환 on 7/1/25.
//

import UIKit

import Moya

enum PartnershipRouter {
    case getAllPartnerships
}

extension PartnershipRouter: TargetType {
    var baseURL: URL {
        URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .getAllPartnerships:
            return "/partnerships"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        return .requestPlain
    }

    var headers: [String: String]? {
        switch self {
        default:
            return ["Content-Type": "application/json"]
        }
    }
}
