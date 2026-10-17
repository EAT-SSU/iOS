//
//  MenuSearchBar.swift
//  EATSSU
//
//  Created by 황상환 on 10/6/26.
//

import UIKit

import SnapKit

import EATSSUDesign

/// 메뉴 찜 검색창: 돋보기 · 입력 · (입력 중) 전체 삭제 버튼
final class MenuSearchBar: BaseUIView {

    // MARK: - Constants

    /// 디자인: 높이 50, 모서리 10, 배경 gray100, 테두리 1 gray200, 돋보기 leading 14, 텍스트 leading 38
    private enum Layout {
        static let height: CGFloat = 50
        static let cornerRadius: CGFloat = 10
        static let iconLeading: CGFloat = 12
        static let iconSize: CGFloat = 16
        static let textLeading: CGFloat = 38
        static let trailing: CGFloat = 8
    }

    // MARK: - UI Components

    let textField = UITextField()
    private let iconImageView = UIImageView()

    // MARK: - View Setup

    override func configureUI() {
        backgroundColor = .gray100
        layer.cornerRadius = Layout.cornerRadius
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray200.cgColor

        let iconConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        iconImageView.image = UIImage(systemName: "magnifyingglass", withConfiguration: iconConfig)
        iconImageView.tintColor = .gray400
        iconImageView.contentMode = .center

        textField.font = .body2
        textField.textColor = .gray700
        textField.tintColor = .gray700
        textField.attributedPlaceholder = NSAttributedString(
            string: TextLiteral.Like.menuSearchPlaceholder,
            attributes: [.font: UIFont.body2, .foregroundColor: UIColor.gray400]
        )
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .search
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no

        addSubviews(iconImageView, textField)
    }

    override func setLayout() {
        snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }

        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Layout.iconLeading)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(Layout.iconSize)
        }

        textField.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Layout.textLeading)
            $0.trailing.equalToSuperview().inset(Layout.trailing)
            $0.top.bottom.equalToSuperview()
        }
    }
}
