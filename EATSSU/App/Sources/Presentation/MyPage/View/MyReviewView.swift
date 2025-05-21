//
//  MyReviewView.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/27.
//

import UIKit

import SnapKit

final class MyReviewView: BaseUIView {
    // MARK: - UI Components

    let myReviewTableView = UITableView()
    let refreshControl = UIRefreshControl()

    // MARK: - Life Cycles

    override init(frame: CGRect) {
        super.init(frame: frame)

        initRefresh()
    }

    // MARK: - Functions

    override func configureUI() {
        addSubview(myReviewTableView)

        myReviewTableView.separatorStyle = .none
        myReviewTableView.showsVerticalScrollIndicator = false
    }

    override func setLayout() {
        myReviewTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func initRefresh() {
        refreshControl.addTarget(self,
                                 action: #selector(refreshTable(refresh:)),
                                 for: .valueChanged)

        myReviewTableView.refreshControl = refreshControl
    }

    @objc
    func refreshTable(refresh: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.myReviewTableView.reloadData()
            refresh.endRefreshing()
        }
    }
}
