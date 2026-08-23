//
//  MapTopTabView.swift
//  EATSSU
//
//  Created by 황상환 on 8/23/26.
//

import UIKit

import SnapKit

import EATSSUDesign

/// 지도 상단 "학교 제휴 / 착한 가격" 언더라인 탭
final class MapTopTabView: BaseUIView {

    // MARK: - Properties

    var onSelect: ((Int) -> Void)?

    private(set) var selectedIndex: Int = 0

    // MARK: - UI Components

    private let stackView = UIStackView()
    private let bottomLine = UIView()
    private let indicatorView = UIView()
    private var buttons: [UIButton] = []

    // MARK: - Init

    init(titles: [String]) {
        super.init(frame: .zero)
        titles.enumerated().forEach { index, title in
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .subtitle1
            button.tag = index
            button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
            buttons.append(button)
        }
        select(index: 0, animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Setup

    override func configureUI() {
        backgroundColor = .white

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill

        bottomLine.backgroundColor = .gray300
        indicatorView.backgroundColor = .primary

        addSubviews(stackView, bottomLine, indicatorView)
    }

    override func setLayout() {
        stackView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        bottomLine.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }

        indicatorView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.height.equalTo(2)
            $0.width.equalToSuperview().dividedBy(max(buttons.count, 1))
            $0.leading.equalToSuperview()
        }
    }

    // MARK: - Selection

    func select(index: Int, animated: Bool) {
        guard buttons.indices.contains(index) else { return }
        selectedIndex = index

        for (buttonIndex, button) in buttons.enumerated() {
            button.setTitleColor(buttonIndex == index ? .primary : .gray500, for: .normal)
        }

        let update = {
            self.layoutIfNeeded()
            let tabWidth = self.bounds.width / CGFloat(max(self.buttons.count, 1))
            self.indicatorView.transform = CGAffineTransform(translationX: tabWidth * CGFloat(index), y: 0)
        }

        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: update)
        } else {
            update()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let tabWidth = bounds.width / CGFloat(max(buttons.count, 1))
        indicatorView.transform = CGAffineTransform(translationX: tabWidth * CGFloat(selectedIndex), y: 0)
    }

    // MARK: - Action

    @objc private func didTapButton(_ sender: UIButton) {
        guard sender.tag != selectedIndex else { return }
        select(index: sender.tag, animated: true)
        onSelect?(sender.tag)
    }
}
