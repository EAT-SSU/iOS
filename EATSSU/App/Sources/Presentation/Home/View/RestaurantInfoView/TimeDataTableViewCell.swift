//
//  TimeDataTableViewCell.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/23.
//

import UIKit

import SnapKit

final class TimeDataTableViewCell: UITableViewCell {
    // MARK: - Properties

    static let identifier = "TimeDataCell"

    // MARK: - UI Components

    private var timepartLabel: UILabel = {
        let label = UILabel()
        label.font = .medium(size: 16)
        label.textColor = .primary
        label.textAlignment = .left
        return label
    }()

    private var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .medium(size: 16)
        label.numberOfLines = 0
        label.textAlignment = .right
        return label
    }()

    // MARK: - init

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

    func configureUI() {
        addSubviews(
            timepartLabel,
            timeLabel
        )
    }

    func setLayout() {
        timepartLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalTo(timeLabel.snp.leading)
            $0.bottom.equalToSuperview().inset(8)
            $0.width.equalTo(40)
        }
        timeLabel.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(8)
        }
        timeLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        timepartLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }

    func bind(timeData: TimeData) {
        timepartLabel.text = timeData.timepart
        let checkedLineTime = timeData.time
        timeLabel.text = checkedLineTime.replacingOccurrences(of: ",", with: "\n")
    }
}
