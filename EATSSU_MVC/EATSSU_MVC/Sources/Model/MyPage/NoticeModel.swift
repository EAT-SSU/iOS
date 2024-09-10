//
//  NoticeModel.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/05/10.
//

import Foundation

struct Notice {
    let title: String
    let date: String
}

extension Notice {
    static func dummy() -> [Notice] {
        return [Notice(title: "더키친 샐러드 오픈기념 할인 EVENT",
                       date: "2023.03.06"),
                Notice(title: "숭실대 더 키친 새롭게 오픈합니다.",
                       date: "2023.03.02"),
                Notice(title: "잇슈 앱 새로 만드는 중 입니다",
                       date: "2023.05.10")]
    }
}
