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

    let refreshControl = UIRefreshControl()

    lazy var restaurantTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.backgroundColor = EATSSUDesignAsset.Color.GrayScale.gray100.color
        return tableView
    }()

    // MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)

        initRefresh()
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

    func initRefresh() {
        refreshControl.addTarget(self,
                                 action: #selector(refreshTable(refresh:)),
                                 for: .valueChanged)

        restaurantTableView.refreshControl = refreshControl
    }

    @objc
    func refreshTable(refresh: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.restaurantTableView.reloadData()
            refresh.endRefreshing()
        }
    }
}
