//
//  AccountStorage.swift
//  EATSSU
//
//  Created by 황상환 on 9/27/26.
//

import Foundation

/// 계정 단위로 로컬에 남는 상태를 한 번에 정리한다 (로그아웃·탈퇴·세션 만료).
enum AccountStorage {
    static func reset() {
        TokenStore.clear()
        UserInfoManager.shared.clear()
        // 찜 목록·순서
        PartnershipLikeManager.shared.reset()
    }
}
