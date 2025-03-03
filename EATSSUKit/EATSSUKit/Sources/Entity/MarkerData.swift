//
//  MarkerData.swift
//  EATSSUKit
//
//  Created by JIWOONG CHOI on 1/31/25.
//

import Foundation

/// 마커에 대한 상세 정보를 담는 구조체
public struct MarkerData: Equatable {
    public let id: Int
    public let title: String
    public let description: String

    public init(id: Int, title: String, description: String) {
        self.id = id
        self.title = title
        self.description = description
    }
}
