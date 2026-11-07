//
//  NotificationCell.swift
//  EATSSU
//
//  Created by 황상환 on 11/7/26.
//

import UIKit

import SnapKit

import EATSSUDesign

/// 알림함 한 줄: 확성기 아이콘 · 제목 · 시각 · 본문. 안 읽은 알림은 민트 배경
///
/// 디자인(390 기준): 행 높이 84(본문 한 줄), 아이콘 원 35 좌측 24, 글 시작 76, 제목 Bold 14, 본문·시각 12, 우측 24
/// 제목·본문은 길어도 말줄임 없이 다음 줄로 넘긴다
final class NotificationCell: UITableViewCell {

    // MARK: - Constants

    static let identifier = "NotificationCell"

    private enum Layout {
        static let horizontalInset: CGFloat = 24
        static let verticalInset: CGFloat = 20
        static let iconSize: CGFloat = 35
        static let iconImageSize = CGSize(width: 20, height: 16)
        static let textLeading: CGFloat = 76
        static let titleBodySpacing: CGFloat = 13
        static let titleTimeSpacing: CGFloat = 8
    }

    // MARK: - UI Components

    private let iconContainerView = UIView()
    private let iconImageView = UIImageView(image: EATSSUDesignAsset.Images.icMegaphone.image)
    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    private let bodyLabel = UILabel()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
        setLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Setup

    private func configureUI() {
        selectionStyle = .none

        iconContainerView.backgroundColor = .white
        iconContainerView.layer.cornerRadius = Layout.iconSize / 2
        iconContainerView.layer.borderWidth = 1
        iconContainerView.layer.borderColor = UIColor.primary.cgColor
        iconImageView.contentMode = .scaleAspectFit

        titleLabel.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 14)
        titleLabel.textColor = .gray700
        titleLabel.numberOfLines = 0

        timeLabel.font = .caption2
        timeLabel.textColor = .gray600
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)

        bodyLabel.font = .caption2
        bodyLabel.textColor = .gray600
        bodyLabel.numberOfLines = 0

        iconContainerView.addSubview(iconImageView)
        contentView.addSubviews(iconContainerView, titleLabel, timeLabel, bodyLabel)
    }

    private func setLayout() {
        iconContainerView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Layout.horizontalInset)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(Layout.iconSize)
        }
        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(Layout.iconImageSize)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(Layout.verticalInset)
            $0.leading.equalToSuperview().inset(Layout.textLeading)
            $0.trailing.lessThanOrEqualTo(timeLabel.snp.leading).offset(-Layout.titleTimeSpacing)
        }
        timeLabel.snp.makeConstraints {
            $0.firstBaseline.equalTo(titleLabel.snp.firstBaseline)
            $0.trailing.equalToSuperview().inset(Layout.horizontalInset)
        }
        bodyLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(Layout.titleBodySpacing)
            $0.leading.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.bottom.equalToSuperview().inset(Layout.verticalInset)
        }
    }

    // MARK: - Configuration

    func configure(title: String, body: String, time: String?, isRead: Bool) {
        titleLabel.text = title
        bodyLabel.text = body
        timeLabel.text = time
        contentView.backgroundColor = isRead ? .white : .secondary
        backgroundColor = contentView.backgroundColor
    }
}
