//
//  MenuChipFlowView.swift
//  EATSSU
//
//  Created by 황상환 on 11/8/26.
//

import UIKit

import EATSSUDesign

/// 메뉴명 칩을 가로로 늘어놓다가 폭이 모자라면 다음 줄로 넘기는 뷰 (다국어 메뉴명 길이 대응)
///
/// 디자인: 칩 높이 27, 모서리 13.5, 좌우 안쪽 9, Medium 10, 가로 간격 7, 세로 간격 9
/// 기본: 흰 배경 · gray300 테두리 · gray600 글자 / 선택: secondary 배경 · primary 테두리 · gray700 글자
final class MenuChipFlowView: UIView {

    // MARK: - Types

    struct Item: Equatable {
        let id: Int
        let title: String
        /// 이미 찜한 메뉴. 선택된 모양으로 보이고 누를 수 없다 (해제는 "내가 찜한 메뉴" 목록에서만)
        let isLocked: Bool
    }

    // MARK: - Constants

    private enum Layout {
        static let chipHeight: CGFloat = 27
        static let horizontalPadding: CGFloat = 9
        static let horizontalSpacing: CGFloat = 7
        static let verticalSpacing: CGFloat = 9
    }

    // MARK: - Properties

    var onSelectionChanged: ((Set<Int>) -> Void)?

    private(set) var items: [Item] = []
    private(set) var selectedIds: Set<Int> = []
    private var chips: [UIButton] = []
    private var lastLayoutWidth: CGFloat = 0
    private var contentHeight: CGFloat = 0

    // MARK: - Configuration

    func configure(items: [Item], selectedIds: Set<Int>) {
        self.items = items
        self.selectedIds = selectedIds.intersection(Set(items.filter { !$0.isLocked }.map(\.id)))
        chips.forEach { $0.removeFromSuperview() }
        chips = items.enumerated().map { index, item in
            let chip = UIButton(type: .custom)
            chip.setTitle(item.title, for: .normal)
            chip.titleLabel?.font = .caption3
            chip.titleLabel?.lineBreakMode = .byTruncatingTail
            chip.contentEdgeInsets = UIEdgeInsets(top: 0, left: Layout.horizontalPadding, bottom: 0, right: Layout.horizontalPadding)
            chip.layer.cornerRadius = Layout.chipHeight / 2
            chip.layer.borderWidth = 1
            chip.tag = index
            chip.isEnabled = !item.isLocked
            chip.addTarget(self, action: #selector(didTapChip(_:)), for: .touchUpInside)
            addSubview(chip)
            return chip
        }
        applySelection()
        lastLayoutWidth = 0
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }

    func clearSelection() {
        selectedIds = []
        applySelection()
    }

    // MARK: - Layout

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: contentHeight)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = bounds.width
        guard width > 0 else { return }
        var x: CGFloat = 0
        var y: CGFloat = 0
        for chip in chips {
            let fitting = chip.sizeThatFits(CGSize(width: width, height: Layout.chipHeight))
            let chipWidth = min(ceil(fitting.width), width)
            if x > 0, x + chipWidth > width {
                x = 0
                y += Layout.chipHeight + Layout.verticalSpacing
            }
            chip.frame = CGRect(x: x, y: y, width: chipWidth, height: Layout.chipHeight)
            x += chipWidth + Layout.horizontalSpacing
        }
        let newHeight = chips.isEmpty ? 0 : y + Layout.chipHeight
        if newHeight != contentHeight || width != lastLayoutWidth {
            contentHeight = newHeight
            lastLayoutWidth = width
            invalidateIntrinsicContentSize()
        }
    }

    // MARK: - Private

    @objc private func didTapChip(_ sender: UIButton) {
        guard items.indices.contains(sender.tag) else { return }
        let id = items[sender.tag].id
        if selectedIds.contains(id) {
            selectedIds.remove(id)
        } else {
            selectedIds.insert(id)
        }
        applySelection()
        onSelectionChanged?(selectedIds)
    }

    private func applySelection() {
        for (chip, item) in zip(chips, items) {
            let isHighlighted = item.isLocked || selectedIds.contains(item.id)
            chip.backgroundColor = isHighlighted ? .secondary : .white
            chip.layer.borderColor = (isHighlighted ? UIColor.primary : UIColor.gray300).cgColor
            chip.setTitleColor(isHighlighted ? .gray700 : .gray600, for: .normal)
            chip.setTitleColor(.gray700, for: .disabled)
        }
    }
}
