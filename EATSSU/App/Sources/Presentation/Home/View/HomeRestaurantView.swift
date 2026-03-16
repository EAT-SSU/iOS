//
//  HomeRestaurantView.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/08/08.
//

import UIKit

import Moya
import SnapKit

import EATSSUDesign

final class HomeRestaurantView: BaseUIView {
    // MARK: - UI Components

    lazy var restaurantTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.backgroundColor = .gray100
        return tableView
    }()

    // MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    // MARK: - Functions

    override func configureUI() {
        addSubviews(restaurantTableView)
    }

    override func setLayout() {
        restaurantTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
