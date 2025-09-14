//
//  URLRequest+.swift
//  EATSSU
//
//  Created by 최지우 on 4/22/25.
//

import Foundation

extension URLRequest {
    var requiresToken: Bool {
        guard let path = self.url?.path else {
            return false
        }
        return !NoAuthRequiredPath.contains(path)
    }
}
