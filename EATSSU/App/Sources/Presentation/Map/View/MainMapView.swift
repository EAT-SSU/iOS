//
//  MainMapView.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 6/24/25.
//

import UIKit

import NMapsMap
import SnapKit

import EATSSUDesign

/// 지도 상단 탭
enum MapTab: Int, CaseIterable {
    case partnership
    case goodPrice

    var title: String {
        switch self {
        case .partnership: return TextLiteral.Map.schoolPartnershipTab
        case .goodPrice:   return TextLiteral.Map.goodPriceTab
        }
    }
}

/// 학교 제휴 탭 필터. festival은 Remote Config로 노출 여부 결정
enum PartnershipFilter: CaseIterable {
    case festival
    case all
    case restaurant
    case cafe
    case pub

    var title: String {
        switch self {
        case .festival:   return TextLiteral.Map.festival
        case .all:        return TextLiteral.Map.all
        case .restaurant: return TextLiteral.Map.restaurant
        case .cafe:       return TextLiteral.Map.cafe
        case .pub:        return TextLiteral.Map.pub
        }
    }

    /// 서버 restaurantType 값. 전체/축제는 nil
    var restaurantType: String? {
        switch self {
        case .restaurant: return "RESTAURANT"
        case .cafe:       return "CAFE"
        case .pub:        return "PUB"
        case .festival, .all: return nil
        }
    }
}

final class MainMapView: BaseUIView {

    // MARK: - UI Components

    let mapView = NMFNaverMapView()
    let topTabView = MapTopTabView(titles: MapTab.allCases.map { $0.title })
    let filterChipBar = MapFilterChipBar()

    // MARK: - UI Setup

    override func configureUI() {
        backgroundColor = .white

        mapView.showZoomControls = false
        mapView.showLocationButton = true
        mapView.mapView.positionMode = .disabled

        addSubviews(mapView, topTabView, filterChipBar)
    }

    // MARK: - Layout Setup

    override func setLayout() {
        topTabView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }

        mapView.snp.makeConstraints {
            $0.top.equalTo(topTabView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        filterChipBar.snp.makeConstraints {
            $0.top.equalTo(mapView).offset(12)
            $0.leading.trailing.equalToSuperview()
        }
    }

    // MARK: - Configuration

    /// 단독 진입(착한가격업소 지도)에서는 상단 탭을 숨긴다
    func setTopTabVisible(_ visible: Bool) {
        topTabView.isHidden = !visible
        topTabView.snp.remakeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            if !visible { $0.height.equalTo(0) }
        }
    }
}
