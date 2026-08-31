//
//  MenuLikePlaceholderViewController.swift
//  EATSSU
//
//  Created by 황상환 on 8/30/26.
//

import UIKit

import SnapKit

/// 메뉴 찜 탭. 서버 API 준비 전까지 안내 문구만 표시
final class MenuLikePlaceholderViewController: BaseViewController {

    private let emptyView = EmptyStateView()

    override func configureUI() {
        view.backgroundColor = .white
        emptyView.configure(
            title: TextLiteral.Like.menuComingSoonTitle,
            subtitle: TextLiteral.Like.menuComingSoonSubtitle
        )
        view.addSubview(emptyView)
    }

    override func setLayout() {
        emptyView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
