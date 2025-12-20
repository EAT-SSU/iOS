//
//  MyPageTableDefaultCell.swift
//  EATSSU_MVC
//
//  Created by Jiwoong CHOI on 9/19/24.
//

import UIKit

import SnapKit

import EATSSUDesign

final class MyPageTableDefaultCell: UITableViewCell {
    // MARK: - Properties

    static let identifier = "MyPageTableDefaultCell"

    // MARK: - UI Components

    let serviceLabel: UILabel = {
        let label = UILabel()
        label.font = .body1
        label.textColor = .gray700Basic
        return label
    }()

    let rigthChevronImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .gray300
        return imageView
    }()

    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureUI()
        setLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions

    private func configureUI() {
        addSubviews(
            serviceLabel,
            rigthChevronImage
        )
    }

    private func setLayout() {
        serviceLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.centerY.equalToSuperview()
        }
        rigthChevronImage.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalToSuperview()
        }
    }
}
