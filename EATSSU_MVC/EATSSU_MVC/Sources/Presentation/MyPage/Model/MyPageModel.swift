//
//  MyPageModel.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/25.
//

import Foundation

struct MyPageLocalData: AppData {
    let titleLabel: String
}

extension MyPageLocalData {
    static let myPageServiceLabelList = [
      MyPageLocalData(titleLabel: TextLiteral.myReview),
      MyPageLocalData(titleLabel: TextLiteral.inquiry),
      MyPageLocalData(titleLabel: TextLiteral.termsOfUse),
      MyPageLocalData(titleLabel: TextLiteral.privacyTermsOfUse),
      MyPageLocalData(titleLabel: TextLiteral.logout),
      MyPageLocalData(titleLabel: TextLiteral.withdraw),
      MyPageLocalData(titleLabel: TextLiteral.creators),
      MyPageLocalData(titleLabel: TextLiteral.appVersion)]
}

struct MyPageRightItemData: AppData {
    let rightArrow: String
    let appVersion: String?
    
    static var version: String? {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String,
              let build = dictionary["CFBundleVersion"] as? String else { return nil }

        let versionAndBuild: String = "\(version)"
        return versionAndBuild
    }
}

extension MyPageRightItemData {
    static let myPageRightItemList = [MyPageRightItemData(rightArrow: ">", appVersion: MyPageRightItemData.version ?? "")]
}
