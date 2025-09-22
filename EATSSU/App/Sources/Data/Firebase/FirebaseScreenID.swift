//
//  FirebaseScreenID.swift
//  EATSSU
//
//  Created by 한금준 on 8/23/25.
//

import Foundation

enum FirebaseScreenID {
    /// 로그인
    enum Login {
            static let log1 = "LOG_001000"
            static let log2 = "LOG_001001"
            static let log3 = "LOG_002000"
            static let log4 = "LOG_002001"
    }
    
    /// 메인페이지
    enum Home {
        static let home1 = "MNU_001000"
        static let home2 = "MNU_002000"
    }
    
    /// 리뷰
    enum Review {

        enum V1 {
                static let review_v1_1 = "REV_001000_V1"
                static let review_v1_2 = "REV_001001_V1"
                static let review_v1_3 = "REV_001002_V1"
                static let review_v1_4 = "REV_001003_V1"
                static let review_v1_5 = "REV_002000"
        }
        
        enum V2 {
                static let review_v2_1 = "REV_001000_V2"
                static let review_v3_1 = "REV_001000_V3"
                static let review_v2_3 = "REV_001001"
                static let review_v2_4 = "REV_003001"
                static let review_v2_5 = "REV_001003"
                static let review_v2_6 = "REV_002000"
        }
    }
    
    /// 지도
    enum Map {
            static let map1 = "MAP_001000"
            static let map2 = "MAP_001001"
            static let map3 = "MAP_001002"
            static let map4 = "MAP_002000"
    }
    
    /// 마이페이지
    enum MyPage {
            static let mypage1 = "MYP_001000"
            static let mypage2 = "MYP_001001"
            static let mypage3 = "MYP_001002"
            static let mypage4 = "MYP_001003"
            static let mypage5 = "MYP_001004"
    }
}
