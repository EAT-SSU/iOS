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

    /// 리뷰 목록 테이블뷰
    let myReviewTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .white
        return tableView
    }()
    
    /// 빈 상태 이미지뷰 (필요한 경우)
    let noReviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()

    // MARK: - Life Cycles

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    // MARK: - Functions

    override func configureUI() {
        backgroundColor = .white
        
        addSubviews(myReviewTableView, noReviewImageView)
    }

    override func setLayout() {
        myReviewTableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        noReviewImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(200)
        }
    }
}
