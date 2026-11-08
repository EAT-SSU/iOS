//
//  DateFormatter+.swift
//  EATSSU
//
//  Created by 황상환 on 11/8/26.
//

import Foundation

extension DateFormatter {
    /// 서버 식단 날짜 형식 `yyyyMMdd` (학식 조회 · 푸시 `date` · 오늘 식단 찜하기 공용)
    /// 사용자 달력·로케일 설정에 영향받지 않도록 그레고리력 · en_US_POSIX로 고정하고, 날짜 경계는 기기 시간대를 따른다
    static let serverDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()
}
