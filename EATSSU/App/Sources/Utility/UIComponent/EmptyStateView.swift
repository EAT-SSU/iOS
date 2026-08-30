//
//  EmptyStateView.swift
//  EATSSU
//
//  Created by 황상환 on 8/30/26.
//

import UIKit

import SnapKit

import EATSSUDesign

/// 목록이 비었을 때 가운데에 메인/서브 카피를 보여주는 공용 뷰
final class EmptyStateView: BaseUIView {

    // MARK: - UI Components

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let stackView = UIStackView()

    // MARK: - View Setup

    override func configureUI() {
        backgroundColor = .clear

        titleLabel.font = .subtitle1
        titleLabel.textColor = .gray700
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        subtitleLabel.font = .body3
        subtitleLabel.textColor = .gray500
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)

        addSubview(stackView)
    }

    override func setLayout() {
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
        }
    }

    // MARK: - Configuration

    func configure(title: String, subtitle: String?) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = (subtitle ?? "").isEmpty
    }
}
