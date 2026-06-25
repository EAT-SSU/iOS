//
//  RadioSelectionTableViewCell.swift
//  EATSSU
//
//  Created by jeongminji on 5/3/26.
//

import UIKit

import SnapKit

import EATSSUDesign

final class RadioSelectionTableViewCell: UITableViewCell {
    // MARK: - Properties

    static let identifier = "RadioSelectionTableViewCell"

    // MARK: - UI Components

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .body1
        label.textColor = .black
        return label
    }()

    private let radioButton: CustomRadioButton = {
        let button = CustomRadioButton()
        button.isUserInteractionEnabled = false
        return button
    }()

    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureUI()
        setLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions

    private func configureUI() {
        contentView.addSubviews(
            titleLabel,
            radioButton
        )
    }

    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(24)
            $0.centerY.equalToSuperview()
        }

        radioButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }
    }

    func configure(
        title: String,
        isSelected: Bool
    ) {
        titleLabel.text = title
        radioButton.updateState(isSelected: isSelected)
    }
}
