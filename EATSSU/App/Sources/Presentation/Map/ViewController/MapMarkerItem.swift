//
//  MapMarkerItem.swift
//  EATSSU
//
//  Created by 황상환 on 8/23/26.
//

import UIKit

/// 지도 마커 하나를 그리기 위한 공통 데이터 (제휴/착한가격 공용)
struct MapMarkerItem {
    let title: String
    let latitude: Double
    let longitude: Double
    let icon: UIImage?
    let onTap: () -> Void
}
