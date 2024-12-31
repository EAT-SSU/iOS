//
//  RestaurantInfoViewController.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/08/29.
//

import SnapKit

import Moya

final class RestaurantInfoViewController: BaseViewController {
    // MARK: - UI Components

    private let restaurantInfoView = RestaurantInfoView()

    // MARK: - Functions

    override func configureUI() {
        view.addSubview(restaurantInfoView)
    }

    override func setLayout() {
        restaurantInfoView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - RestaurantInfoDelegate

extension RestaurantInfoViewController: RestaurantInfoDelegate {
    func didTappedRestaurantInfo(restaurantName: String) {
        restaurantInfoView.restaurantNameLabel.text = restaurantName
        if let restaurantInfo = RestaurantInfoData.restaurantInfoData.first(where: { $0.name == restaurantName }) {
            restaurantInfoView.bind(data: restaurantInfo)
        }
    }
}
