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
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    /// 리뷰 상단 summary
    let summaryView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    /// 리뷰 리스트
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .yellow
        tableView.rowHeight = UITableView.automaticDimension
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    /// 리뷰작성
    public let writingReviewButton = ESButton(size: .big, title: "리뷰 작성하기")
    
    // MARK: - Functions
    
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
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(writingReviewButton.snp.top).offset(-10)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            // TODO: 수정 필요
            make.height.equalTo(2000)
        }
        summaryView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(200)
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


