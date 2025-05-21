//
//  NotificationSettingTableViewCell.swift
//  EATSSU
//
//  Created by Jiwoong CHOI on 9/19/24.
//

import UIKit

import SnapKit

import EATSSUDesign

class NotificationSettingTableViewCell: UITableViewCell {
    // MARK: - Properties

    static let identifier = "NotificationSettingTableViewCell"

    // MARK: - UI Components

    // "푸시 알림 설정"
    private let pushNotificationTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "푸시 알림 설정"
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 16)
        label.textColor = .black
        return label
    }()

    // "매일 오전 11시에 알림을 보내드려요"
    private let dailyNotificationInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "매일 오전 11시에 알림을 보내드려요"
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 12)
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray400.color
        return label
    }()

    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    let toggleSwitch: UISwitch = {
        let toggleSwitch = UISwitch()
        toggleSwitch.onTintColor = EATSSUDesignAsset.Color.Main.primary.color
        toggleSwitch.isOn = UserDefaults.standard.bool(forKey: TextLiteral.MyPage.pushNotificationUserSettingKey)
        return toggleSwitch
    }()

    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureUI()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    private func configureUI() {
        addSubviews(
            pushNotificationTitleLabel,
            dailyNotificationInfoLabel,
            labelStackView,
            toggleSwitch
        )
    }

    private func setupLayout() {
        labelStackView.addArrangedSubviews([pushNotificationTitleLabel, dailyNotificationInfoLabel])

        labelStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }

        toggleSwitch.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }
    }
}
