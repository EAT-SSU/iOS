//
//  FixedMenuInfoModel.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/17.
//

import Foundation

struct FixedMenuInfoData: MenuType {
    let menuID: Int
    let name: String
    let mainGrade: Double
    let price: Int
}

extension FixedMenuInfoData {
    static func Dummy() -> [FixedMenuInfoData] {
        return [ .init(menuID: 45, name: "탄단지샐러드", mainGrade: 0, price: 7500),
                 .init(menuID: 46, name: "콥샐러드", mainGrade: 0, price: 7000),
                 .init(menuID: 47, name: "리코타치즈샐러드", mainGrade: 0, price: 8000),
                 .init(menuID: 48, name: "훈제연어샐러드", mainGrade: 0, price: 3700),
                 .init(menuID: 49, name: "비건두부샐러드", mainGrade: 0, price: 5900),
                 .init(menuID: 50, name: "얼그레이버블티", mainGrade: 0, price: 3000),
                 .init(menuID: 51, name: "흑당버블티", mainGrade: 0, price: 2300)]
    }
}
