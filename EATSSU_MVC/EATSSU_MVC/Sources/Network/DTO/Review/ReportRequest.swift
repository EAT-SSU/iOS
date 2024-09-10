//
//  ReportRequest.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/08/16.
//

import UIKit

struct ReportRequest: Codable {
    let reviewId: Int
    let reportType: String
    let content: String
    
    init(reviewId: Int, reportType: String, content: String) {
        self.reviewId = reviewId
        self.reportType = reportType
        self.content = content
    }
}
