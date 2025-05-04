//
//  RestaurantMenuGroupCell.swift
//  EATSSU
//
//  Created by 황상환 on 4/6/25.
//

import UIKit

import EATSSUDesign

import SnapKit

final class RestaurantMenuGroupCell: BaseTableViewCell {
    static let identifier = "RestaurantMenuGroupCell"

    private let wrapperView = UIView()
    private let titleView = RestaurantMenuTitleView()
    private let menuStackView = UIStackView()

    private let emptyLabel = UILabel().then {
        $0.text = "영업 시간이 아니에요."
        $0.font = .semiBold(size: 10)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.isHidden = true
    }

    override func configureUI() {
        contentView.addSubview(wrapperView)
        wrapperView.addSubviews(titleView, emptyLabel, menuStackView)

        wrapperView.layer.cornerRadius = 12
        wrapperView.layer.borderWidth = 1
        wrapperView.layer.borderColor = UIColor.gray200.cgColor
        wrapperView.backgroundColor = .white

        menuStackView.axis = .vertical
    }

    override func setLayout() {
        wrapperView.snp.makeConstraints { $0.edges.equalToSuperview() }

        titleView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
        }

        emptyLabel.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().inset(16)
        }

        menuStackView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }

    func configure(with menus: [MenuTypeInfo], at indexPath: IndexPath, onMenuTap: @escaping (IndexPath, Int) -> Void) {
        menuStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if menus.isEmpty {
            emptyLabel.isHidden = false
            menuStackView.isHidden = true
        } else {
            emptyLabel.isHidden = true
            menuStackView.isHidden = false

            for (idx, menu) in menus.enumerated() {
                let itemView = RestaurantMenuItemView()
                itemView.indexPath = indexPath
                itemView.menuIndex = idx       
                itemView.onTap = onMenuTap
                itemView.bind(menu)
                menuStackView.addArrangedSubview(itemView)
            }

        }
    }
}
