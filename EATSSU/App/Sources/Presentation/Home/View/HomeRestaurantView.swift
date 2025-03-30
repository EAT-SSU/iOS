//
//  HomeRestaurantView.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/08/08.
//

import UIKit

import EATSSUDesign

import Moya
import SnapKit
import Then

final class HomeRestaurantView: BaseUIView {
    // MARK: - UI Components

    let refreshControl = UIRefreshControl()

    lazy var restaurantTableView = UITableView(frame: .zero, style: .insetGrouped).then {
        $0.separatorStyle = .none
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.backgroundColor = EATSSUDesignAsset.Color.GrayScale.gray100.color
    }

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
            $0.top.equalToSuperview().inset(-10)
            $0.leading.bottom.trailing.equalToSuperview()
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
