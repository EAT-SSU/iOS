//
//  TodayMenuFavoriteCardView.swift
//  EATSSU
//
//  Created by 황상환 on 11/8/26.
//

import UIKit

import SnapKit

import EATSSUDesign

/// "오늘 식단에서 찜하기" 카드. 접힌 상태는 제목 한 줄, 펼치면 식당·시간대 · 변경 버튼 · 메뉴 칩 · 찜하기 버튼
///
/// 디자인(390 기준): 카드 좌우 24, 모서리 8, gray300 테두리. 헤더 41(아이콘 20 좌 9, 제목 Medium 12, 화살표 우 9)
/// 펼침: 식당·시간대 Bold 16(좌 11, 헤더 아래 10) · 변경 36×25(우 11) · 안내 Medium 12 gray400(아래 6)
///       칩 영역(안내 아래 16, 좌우 9) · 버튼 40(칩 아래 12, 좌우 9, 모서리 8) · 아래 여백 10
final class TodayMenuFavoriteCardView: UIView {

    // MARK: - Constants

    private enum Layout {
        static let cornerRadius: CGFloat = 8
        static let headerHeight: CGFloat = 41
        static let iconLeading: CGFloat = 9
        static let iconSize: CGFloat = 20
        static let titleLeading: CGFloat = 33
        static let chevronTrailing: CGFloat = 9
        static let textInset: CGFloat = 11
        static let contentInset: CGFloat = 9
        static let slotTop: CGFloat = 10
        static let hintTop: CGFloat = 6
        static let chipsTop: CGFloat = 16
        static let buttonTop: CGFloat = 12
        static let buttonHeight: CGFloat = 40
        static let buttonCornerRadius: CGFloat = 8
        static let bottomInset: CGFloat = 10
        static let changeButtonSize = CGSize(width: 36, height: 25)
        static let disabledAlpha: CGFloat = 0.5
    }

    // MARK: - Properties

    var onToggle: (() -> Void)?
    var onTapChange: (() -> Void)?
    var onTapSubmit: (() -> Void)?
    /// 선택이 바뀌어 버튼 문구가 바뀔 때. 높이는 변하지 않는다
    var onSelectionChanged: ((Set<Int>) -> Void)?

    private(set) var isExpanded = false

    var selectedIds: Set<Int> { chipFlowView.selectedIds }

    /// 접힘: 헤더 바닥 = 카드 바닥 / 펼침: 내용 바닥 = 카드 바닥. 둘 중 하나만 켠다
    private var collapsedBottomConstraint: Constraint?
    private var expandedBottomConstraint: Constraint?

    // MARK: - UI Components

    private let headerButton = UIButton(type: .custom)
    private let iconImageView = UIImageView(image: EATSSUDesignAsset.Images.icCalendar.image)
    private let titleLabel = UILabel()
    private let chevronImageView = UIImageView()

    private let contentView = UIView()
    private let slotLabel = UILabel()
    private let changeButton = UIButton(type: .system)
    private let hintLabel = UILabel()
    /// 칩 또는 "메뉴 없음" 문구가 들어가는 영역. 둘 중 큰 쪽 높이를 가진다
    private let chipAreaView = UIView()
    private let chipFlowView = MenuChipFlowView()
    private let noMenuLabel = UILabel()
    private let submitButton = UIButton(type: .custom)

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Setup

    private func configureUI() {
        backgroundColor = .white
        layer.cornerRadius = Layout.cornerRadius
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray300.cgColor
        clipsToBounds = true

        iconImageView.tintColor = .gray400
        iconImageView.contentMode = .scaleAspectFit

        titleLabel.text = TextLiteral.Like.todayMenuToggle
        titleLabel.font = .caption2
        titleLabel.textColor = .gray700

        let chevronConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        chevronImageView.image = UIImage(systemName: "chevron.down", withConfiguration: chevronConfig)
        chevronImageView.tintColor = .gray400
        chevronImageView.contentMode = .center

        slotLabel.font = .subtitle1
        slotLabel.textColor = .gray700

        changeButton.setTitle(TextLiteral.Like.change, for: .normal)
        changeButton.titleLabel?.font = .caption2
        changeButton.setTitleColor(.gray600, for: .normal)
        changeButton.layer.cornerRadius = 4
        changeButton.layer.borderWidth = 1
        changeButton.layer.borderColor = UIColor.gray300.cgColor

        hintLabel.text = TextLiteral.Like.todayMenuHint
        hintLabel.font = .caption2
        hintLabel.textColor = .gray400

        noMenuLabel.text = TextLiteral.Home.noMenuProvidedMessage
        noMenuLabel.font = .caption2
        noMenuLabel.textColor = .gray500
        noMenuLabel.isHidden = true

        submitButton.titleLabel?.font = .button2
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.backgroundColor = .primary
        submitButton.layer.cornerRadius = Layout.buttonCornerRadius

        contentView.isHidden = true

        headerButton.accessibilityIdentifier = "like.todayMenuCard.header"
        headerButton.accessibilityLabel = TextLiteral.Like.todayMenuToggle
        changeButton.accessibilityIdentifier = "like.todayMenuCard.change"
        submitButton.accessibilityIdentifier = "like.todayMenuCard.submit"
        headerButton.addTarget(self, action: #selector(didTapHeader), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(didTapChange), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
        chipFlowView.onSelectionChanged = { [weak self] ids in
            self?.updateSubmitButton()
            self?.onSelectionChanged?(ids)
        }

        chipAreaView.addSubviews(chipFlowView, noMenuLabel)
        contentView.addSubviews(slotLabel, changeButton, hintLabel, chipAreaView, submitButton)
        addSubviews(headerButton, iconImageView, titleLabel, chevronImageView, contentView)
        updateSubmitButton()
    }

    private func setLayout() {
        headerButton.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Layout.headerHeight)
            collapsedBottomConstraint = $0.bottom.equalToSuperview().constraint
        }
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Layout.iconLeading)
            $0.centerY.equalTo(headerButton)
            $0.size.equalTo(Layout.iconSize)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Layout.titleLeading)
            $0.centerY.equalTo(headerButton)
            $0.trailing.lessThanOrEqualTo(chevronImageView.snp.leading).offset(-8)
        }
        chevronImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(Layout.chevronTrailing)
            $0.centerY.equalTo(headerButton)
            $0.size.equalTo(18)
        }

        contentView.snp.makeConstraints {
            $0.top.equalTo(headerButton.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            expandedBottomConstraint = $0.bottom.equalToSuperview().constraint
        }
        expandedBottomConstraint?.deactivate()

        slotLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.slotTop)
            $0.leading.equalToSuperview().inset(Layout.textInset)
            $0.trailing.lessThanOrEqualTo(changeButton.snp.leading).offset(-8)
        }
        changeButton.snp.makeConstraints {
            $0.centerY.equalTo(slotLabel)
            $0.trailing.equalToSuperview().inset(Layout.textInset)
            $0.size.equalTo(Layout.changeButtonSize)
        }
        hintLabel.snp.makeConstraints {
            $0.top.equalTo(slotLabel.snp.bottom).offset(Layout.hintTop)
            $0.leading.trailing.equalToSuperview().inset(Layout.textInset)
        }
        chipAreaView.snp.makeConstraints {
            $0.top.equalTo(hintLabel.snp.bottom).offset(Layout.chipsTop)
            $0.leading.trailing.equalToSuperview().inset(Layout.contentInset)
            // 칩과 안내 문구 중 보이는 쪽의 높이만큼만 차지한다
            $0.height.equalTo(0).priority(.low)
        }
        chipFlowView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }
        noMenuLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(Layout.textInset - Layout.contentInset)
            $0.bottom.lessThanOrEqualToSuperview()
        }
        submitButton.snp.makeConstraints {
            $0.top.equalTo(chipAreaView.snp.bottom).offset(Layout.buttonTop)
            $0.leading.trailing.equalToSuperview().inset(Layout.contentInset)
            $0.height.equalTo(Layout.buttonHeight)
            $0.bottom.equalToSuperview().inset(Layout.bottomInset)
        }
    }

    // MARK: - Configuration

    func setExpanded(_ expanded: Bool) {
        isExpanded = expanded
        contentView.isHidden = !expanded
        chevronImageView.transform = expanded ? CGAffineTransform(rotationAngle: .pi) : .identity
        if expanded {
            collapsedBottomConstraint?.deactivate()
            expandedBottomConstraint?.activate()
        } else {
            expandedBottomConstraint?.deactivate()
            collapsedBottomConstraint?.activate()
        }
    }

    /// - Parameter showsNoMenu: 메뉴를 받아왔는데 비어 있을 때만 true. 불러오는 중이거나 실패했을 때는 칩 자리를 비워 둔다
    func configure(slot: TodayMenuSlot, items: [MenuChipFlowView.Item], selectedIds: Set<Int>, showsNoMenu: Bool) {
        slotLabel.text = slot.title
        chipFlowView.configure(items: items, selectedIds: selectedIds)
        noMenuLabel.isHidden = !(items.isEmpty && showsNoMenu)
        chipFlowView.isHidden = items.isEmpty
        updateSubmitButton()
    }

    func clearSelection() {
        chipFlowView.clearSelection()
        updateSubmitButton()
    }

    // MARK: - Private

    private func updateSubmitButton() {
        let count = chipFlowView.selectedIds.count
        let title = count == 0 ? TextLiteral.Like.favoriteMenus : TextLiteral.Like.favoriteSelectedMenus(count)
        submitButton.setTitle(title, for: .normal)
        submitButton.isEnabled = count > 0
        submitButton.alpha = count > 0 ? 1 : Layout.disabledAlpha
    }

    @objc private func didTapHeader() {
        onToggle?()
    }

    @objc private func didTapChange() {
        onTapChange?()
    }

    @objc private func didTapSubmit() {
        onTapSubmit?()
    }
}
