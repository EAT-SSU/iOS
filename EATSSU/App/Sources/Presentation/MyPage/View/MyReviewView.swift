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

    // MARK: - Life Cycles

    override init(frame: CGRect) {
        super.init(frame: frame)
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
}
