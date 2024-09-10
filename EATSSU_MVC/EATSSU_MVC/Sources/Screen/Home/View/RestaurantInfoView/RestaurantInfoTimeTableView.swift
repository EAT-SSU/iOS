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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        setupTableView()
    }
    
    override var intrinsicContentSize: CGSize {
        let height = self.contentSize.height + self.contentInset.top + self.contentInset.bottom
        return CGSize(width: self.contentSize.width, height: height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }

    private func setupTableView() {
        self.separatorStyle = .none
        self.isScrollEnabled = false
    }
}
