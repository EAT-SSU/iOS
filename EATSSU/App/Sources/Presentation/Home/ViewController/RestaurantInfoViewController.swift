//
//  RestaurantInfoViewController.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/08/29.
//

import UIKit

import SnapKit

import Moya

final class RestaurantInfoViewController: BaseViewController {
    // MARK: - UI Components

    private let restaurantInfoView = RestaurantInfoView()

    // MARK: - Functions

    override func configureUI() {
        view.addSubview(restaurantInfoView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        logScreenView(screenID: FirebaseScreenID.Home.home2)
    }


    override func setLayout() {
        restaurantInfoView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    /// 컨텐츠에 맞는 시트 높이 (마지막 텍스트 아래 여백 54, 세이프에리어 포함)
    func calculatePreferredHeight() -> CGFloat {
        let targetSize = CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        return view.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
    }
}

// MARK: - RestaurantInfoDelegate

extension RestaurantInfoViewController: RestaurantInfoDelegate {
    func didTappedRestaurantInfo(restaurant: Restaurant) {
        // 이름·위치·시간·비고를 현재 앱 언어로 구성 (한국어는 Remote Config 우선)
        restaurantInfoView.bind(data: RestaurantInfoData.localized(for: restaurant))
    }
}
