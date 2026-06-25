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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        logScreenView(screenID: FirebaseScreenID.Home.home2)
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
        let koreanName = koreanRestaurantName(from: restaurantName)
        if let restaurantInfo = RestaurantInfoData.restaurantInfoData.first(where: { $0.name == koreanName }) {
            restaurantInfoView.bind(data: restaurantInfo)
        }
    }
    
    private func koreanRestaurantName(from name: String) -> String {
        switch name {
        case TextLiteral.Restaurant.dodamRestaurant:
            return "도담 식당"
        case TextLiteral.Restaurant.studentRestaurant:
            return "학생 식당"
        case TextLiteral.Restaurant.snackCorner:
            return "스낵 코너"
        case TextLiteral.Restaurant.dormitoryRestaurant:
            return "기숙사 식당"
        case TextLiteral.Restaurant.facultyRestaurant:
            return "FACULTY (교직원 전용)"
        default:
            return name
        }
    }
}
