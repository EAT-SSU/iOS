//
//  EmptyStateView.swift
//  EATSSU
//
//  Created by 황상환 on 8/30/26.
//

import UIKit

import SnapKit

import EATSSUDesign

/// 목록이 비었을 때 메인/서브 카피를 보여주는 공용 뷰
/// 디자인 기준 문구 위치는 정중앙보다 약간 위(컨테이너 높이의 약 45%)이며 두 줄 모두 회색이다
final class EmptyStateView: BaseUIView {

    // MARK: - UI Components

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let stackView = UIStackView()

    // MARK: - View Setup

    override func configureUI() {
        backgroundColor = .clear

        titleLabel.font = .subtitle2
        titleLabel.textColor = .gray600
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        subtitleLabel.font = .caption2
        subtitleLabel.textColor = .gray600
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
            $0.centerX.equalToSuperview()
            // 정중앙(1.0)보다 위로: 디자인의 문구 위치(화면 약 53%)에 맞춤
            $0.centerY.equalTo(snp.centerY).multipliedBy(0.9)
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
