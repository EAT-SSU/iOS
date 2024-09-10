//
//  BaseTableViewHeaderView.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/08/09.
//

import UIKit

class BaseTableViewHeaderView: UITableViewHeaderFooterView {

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {}
    
}
