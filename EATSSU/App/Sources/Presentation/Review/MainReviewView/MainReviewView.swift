//
//  MainReviewView.swift
//  EATSSU-DEV
//
//  Created by 최지우 on 1/30/25.
//

import UIKit

import SnapKit
import EATSSUDesign

final class MainReviewView: BaseUIView {
    
    // MARK: - Properties
  

    
    // MARK: - UI Components
    
//    private let scrollView = UIScrollView()
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .green
        return sv
    }()
    private let contentView: UIView = {
        let cv = UIView()
        cv.backgroundColor = .gray
        return cv
    }()

    /// 리뷰 상단 summary
    let summaryView = ReviewSummaryView()
    
    /// 리뷰 리스트
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .yellow
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    /// 리뷰작성
    public let writingReviewButton = ESButton(size: .big, title: "리뷰 작성하기")
    
    // MARK: - Functions
    var reviewSummaryHeightConstraint: Constraint?
        var tableViewHeightConstraint: Constraint?
    var a: CGFloat = 1
   
    
   
    
    override func configureUI() {
        addSubviews(
            scrollView,
            writingReviewButton
        )
        scrollView.addSubview(contentView)
        contentView.addSubviews(
            summaryView,
            tableView
        )
    }
    
    override func setLayout() {
        writingReviewButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(5)
        }
        scrollView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(writingReviewButton.snp.top).offset(-10)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
//            make.bottom.equalTo(tableView.snp.bottom).priority(.low)
//            make.height.greaterThanOrEqualTo(scrollView.snp.height)
        }
        summaryView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(summaryView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

#if DEBUG
import SwiftUI

struct Preview: PreviewProvider {
    static var previews: some View {
        MainReviewViewController().toPreview()
    }
}
#endif


