//
//  FilterChipBar.swift
//  EATSSU
//
//  Created by 황상환 on 8/23/26.
//

import UIKit

import SnapKit

import EATSSUDesign

/// 지도 위에 떠 있는 가로 스크롤 필터 칩 바 (단일 선택)
/// 가로 스크롤 필터 칩 바 (단일 선택). 지도 필터와 찜 목록 필터 공용
final class FilterChipBar: BaseUIView {

    // MARK: - Constants

    private enum Layout {
        static let chipHeight: CGFloat = 36
        static let chipSpacing: CGFloat = 8
        static let chipHorizontalPadding: CGFloat = 14
    }

    // MARK: - Properties

    var onSelect: ((Int) -> Void)?

    /// 첫/마지막 칩과 화면 가장자리 사이 여백 (지도 16, 찜 목록 24)
    var horizontalInset: CGFloat = 16 {
        didSet {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        }
    }

    /// 선택 칩 배경색 (축제 필터 등 모드에 따라 변경 가능)
    var highlightColor: UIColor = .primary {
        didSet { applySelection() }
    }

    private(set) var selectedIndex: Int = 0
    private var chips: [UIButton] = []
    private var titles: [String] = []

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    // MARK: - View Setup

    override func configureUI() {
        backgroundColor = .clear

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.clipsToBounds = false
        scrollView.contentInset = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)

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
        self.titles = titles
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
        config.attributedTitle = Self.chipTitle(title, isSelected: false)
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
            if titles.indices.contains(index) {
                chip.configuration?.attributedTitle = Self.chipTitle(titles[index], isSelected: isSelected)
            }
        }
    }

    /// 선택 시 볼드(button2), 미선택 시 미디엄(body2) — 선택 칩은 배경과 같은 색 보더라 보더가 사라진 것처럼 보인다
    private static func chipTitle(_ title: String, isSelected: Bool) -> AttributedString {
        AttributedString(title, attributes: AttributeContainer([.font: isSelected ? UIFont.button2 : UIFont.body2]))
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
