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
    let topTabView = UnderlineTabView(titles: MapTab.allCases.map { $0.title })
    let filterChipBar = FilterChipBar()

    /// 찜 탭으로 이동하는 플로팅 하트 버튼. 필터 칩과 같은 줄 오른쪽에 두고, 칩은 그 왼쪽 영역에서 스크롤된다
    let likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.layer.cornerRadius = 18
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.12
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 6
        button.setImage(EATSSUDesignAsset.Images.icLikeLine.image, for: .normal)
        button.tintColor = .label
        return button
    }()

    // MARK: - UI Setup

    override func configureUI() {
        backgroundColor = .white

        mapView.showZoomControls = false
        mapView.showLocationButton = true
        mapView.mapView.positionMode = .disabled

        addSubviews(mapView, topTabView, filterChipBar, likeButton)
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

        likeButton.snp.makeConstraints {
            $0.top.equalTo(mapView).offset(12)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.height.equalTo(36)
        }

        filterChipBar.snp.makeConstraints {
            $0.top.equalTo(mapView).offset(12)
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(likeButton.snp.leading).offset(-8)
        }
    }

    /// 하트 노출 여부에 따라 칩 바 폭을 조정한다 (숨기면 칩이 오른쪽 끝까지 스크롤)
    func setLikeButtonVisible(_ visible: Bool) {
        likeButton.isHidden = !visible
        filterChipBar.snp.remakeConstraints {
            $0.top.equalTo(mapView).offset(12)
            $0.leading.equalToSuperview()
            if visible {
                $0.trailing.equalTo(likeButton.snp.leading).offset(-8)
            } else {
                $0.trailing.equalToSuperview()
            }
        }
    }

    // MARK: - Configuration

    /// 단독 진입(착한가격업소 지도)에서는 상단 탭을 숨기고 지도를 safe area 상단까지 올린다
    func setTopTabVisible(_ visible: Bool) {
        topTabView.isHidden = !visible
        mapView.snp.remakeConstraints {
            if visible {
                $0.top.equalTo(topTabView.snp.bottom)
            } else {
                $0.top.equalTo(safeAreaLayoutGuide)
            }
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
