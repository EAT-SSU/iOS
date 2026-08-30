//
//  PartnershipDTO.swift
//  EATSSU
//
//  Created by 황상환 on 7/1/25.
//

import Foundation

struct PartnershipDTO: Codable {
    let storeName: String
    let longitude: Double
    let latitude: Double
    let restaurantType: String
    let naverMapUrl: String?
    let kakaoMapUrl: String?
    let partnershipInfos: [PartnershipInfoDTO]
}

struct PartnershipInfoDTO: Codable {
    let id: Int
    let collegeName: String?
    let departmentName: String?
    let likeCount: Int
    let isLiked: Bool
    let description: String
    let startDate: String
    let endDate: String
    let periodType: PartnershipPeriodType
}

extension PartnershipDTO {
    /// 업체 식별 키. 서버 응답에 업체 id가 없어 이름 + 좌표로 구성한다
    var storeKey: String {
        "\(storeName)|\(latitude)|\(longitude)"
    }

    /// 업체에 속한 제휴 항목 id 목록 (찜은 항목 단위 API라 업체 찜 = 모든 항목 찜)
    var partnershipIds: [Int] {
        partnershipInfos.map(\.id)
    }
}

enum PartnershipPeriodType: String, Codable {
    case normal = "NORMAL"
    case festival = "FESTIVAL"
}
