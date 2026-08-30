//
//  MapFilterChipBar.swift
//  EATSSU
//
//  Created by 황상환 on 8/23/26.
//

import UIKit

import SnapKit

import EATSSUDesign

/// 지도 위에 떠 있는 가로 스크롤 필터 칩 바 (단일 선택)
final class MapFilterChipBar: BaseUIView {

    // MARK: - Constants

    private enum Layout {
        static let chipHeight: CGFloat = 36
        static let chipSpacing: CGFloat = 8
        static let horizontalInset: CGFloat = 16
        static let chipHorizontalPadding: CGFloat = 16
    }

    // MARK: - Properties

    var onSelect: ((Int) -> Void)?

    /// 선택 칩 배경색 (축제 필터 등 모드에 따라 변경 가능)
    var highlightColor: UIColor = .primary {
        didSet { applySelection() }
    }

    private(set) var selectedIndex: Int = 0
    private var chips: [UIButton] = []

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    // MARK: - View Setup

    override func configureUI() {
        backgroundColor = .clear

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.clipsToBounds = false
        scrollView.contentInset = UIEdgeInsets(
            top: 0,
            left: Layout.horizontalInset,
            bottom: 0,
            right: Layout.horizontalInset
        )

        stackView.axis = .horizontal
        stackView.spacing = Layout.chipSpacing
        stackView.alignment = .center

        addSubview(scrollView)
        scrollView.addSubview(stackView)
    }

    override func setLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(Layout.chipHeight)
        }

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }
    }

    // MARK: - Configuration

    /// 칩 목록을 교체하고 첫 칩을 선택 상태로 둔다
    func configure(titles: [String], selectedIndex: Int = 0) {
        chips.forEach { $0.removeFromSuperview() }
        chips = titles.enumerated().map { index, title in
            let chip = makeChip(title: title, index: index)
            stackView.addArrangedSubview(chip)
            return chip
        }
        select(index: selectedIndex, animated: false)
    }

    func select(index: Int, animated: Bool = true) {
        guard chips.indices.contains(index) else { return }
        selectedIndex = index
        applySelection()
        scrollToSelectedChip(animated: animated)
    }

    // MARK: - Private

    private func makeChip(title: String, index: Int) -> UIButton {
        let chip = UIButton(type: .custom)
        chip.tag = index
        chip.setContentHuggingPriority(.required, for: .horizontal)
        chip.setContentCompressionResistancePriority(.required, for: .horizontal)
        chip.layer.cornerRadius = Layout.chipHeight / 2
        chip.layer.borderWidth = 1
        chip.clipsToBounds = true
        chip.addTarget(self, action: #selector(didTapChip(_:)), for: .touchUpInside)

        var config = UIButton.Configuration.plain()
        config.buttonSize = .mini
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: Layout.chipHorizontalPadding,
            bottom: 0,
            trailing: Layout.chipHorizontalPadding
        )
        config.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer([.font: UIFont.button2])
        )
        chip.configuration = config

        chip.snp.makeConstraints { $0.height.equalTo(Layout.chipHeight) }
        return chip
    }

    private func applySelection() {
        for (index, chip) in chips.enumerated() {
            let isSelected = index == selectedIndex
            chip.backgroundColor = isSelected ? highlightColor : .white
            chip.layer.borderColor = isSelected ? highlightColor.cgColor : UIColor.gray300.cgColor
            chip.configuration?.baseForegroundColor = isSelected ? .white : .gray500
        }
    }

    /// 선택된 칩이 화면 밖에 있으면 보이도록 스크롤
    private func scrollToSelectedChip(animated: Bool) {
        guard chips.indices.contains(selectedIndex) else { return }
        layoutIfNeeded()
        let chipFrame = chips[selectedIndex].frame
        scrollView.scrollRectToVisible(chipFrame, animated: animated)
    }

    // MARK: - Action

    @objc private func didTapChip(_ sender: UIButton) {
        guard sender.tag != selectedIndex else { return }
        select(index: sender.tag)
        onSelect?(sender.tag)
    }
}
