//
//  RestaurantInfoTimeTableView.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/24.
//

import UIKit

final class RestaurantInfoTimeTableView: UITableView {
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupTableView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        setupTableView()
    }

    override var intrinsicContentSize: CGSize {
        let height = contentSize.height + contentInset.top + contentInset.bottom
        return CGSize(width: contentSize.width, height: height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }

    private func setupTableView() {
        separatorStyle = .none
        isScrollEnabled = false
    }
}
