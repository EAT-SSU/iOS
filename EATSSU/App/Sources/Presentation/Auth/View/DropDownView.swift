//
//  DropDownView.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 6/25/25.
//

import UIKit

import SnapKit

import EATSSUDesign

final class DropDownView: BaseUIView {

    // MARK: - Properties

    private var items: [String]
    public var onSelectItem: ((String) -> Void)?
    private var isDropdownVisible = false
    private var dropdownTableView: UITableView?
    private static var currentlyOpenDropdown: DropDownView?
    private let placeholderTitle: String

    // MARK: - UI Components

    private let button = UIButton(type: .system)
    private let arrow = UIImageView(image: UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate))

    // MARK: - Init

    init(title: String, items: [String]) {
        self.placeholderTitle = title
        self.items = items
        super.init(frame: .zero)
        setButtonEvent()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - View Setup

    override func configureUI() {
        configureButton(title: placeholderTitle)
        arrow.tintColor = EATSSUDesignAsset.Color.GrayScale.gray700.color
        addSubviews(button, arrow)
    }

    override func setLayout() {
        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        arrow.snp.makeConstraints {
            $0.centerY.equalTo(button)
            $0.trailing.equalToSuperview().inset(12)
            $0.width.height.equalTo(16)
        }
    }

    func setButtonEvent() {
        button.addTarget(self, action: #selector(toggleDropdown), for: .touchUpInside)
    }

    // MARK: - Dropdown Control

    /// 드롭다운 토글 처리
    @objc private func toggleDropdown() {
        guard let parentView = self.window else { return }

        // 이미 열려있는 드롭다운이면 닫음
        if DropDownView.currentlyOpenDropdown == self, isDropdownVisible {
            dismissDropdown()
            return
        }

        // 다른 드롭다운이 열려있으면 닫기
        DropDownView.currentlyOpenDropdown?.dismissDropdown()

        // 배경 탭 시 닫히도록 투명 버튼 추가
        let backgroundButton = UIButton()
        backgroundButton.backgroundColor = .clear
        backgroundButton.frame = parentView.bounds
        backgroundButton.addTarget(self, action: #selector(dismissDropdown), for: .touchUpInside)
        backgroundButton.tag = 999
        parentView.addSubview(backgroundButton)

        // 드롭다운 테이블 생성
        let tableView = UITableView()
        tableView.layer.cornerRadius = 12
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = EATSSUDesignAsset.Color.GrayScale.gray300.color.cgColor
        tableView.layer.shadowColor = UIColor.black.cgColor
        tableView.layer.shadowOpacity = 0.1
        tableView.layer.shadowOffset = CGSize(width: 0, height: 2)
        tableView.layer.shadowRadius = 4
        tableView.isScrollEnabled = true
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        parentView.addSubview(tableView)

        // 위치 계산
        let origin = self.convert(self.bounds.origin, to: parentView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(origin.y + 48 + 6)
            $0.leading.equalTo(origin.x)
            $0.width.equalTo(self.bounds.width)
            $0.height.equalTo(min(items.count * 44, 200))
        }

        dropdownTableView = tableView
        isDropdownVisible = true
        DropDownView.currentlyOpenDropdown = self
    }

    /// 드롭다운 닫기
    @objc public func dismissDropdown() {
        dropdownTableView?.superview?.viewWithTag(999)?.removeFromSuperview()
        dropdownTableView?.removeFromSuperview()
        dropdownTableView = nil
        isDropdownVisible = false

        if DropDownView.currentlyOpenDropdown == self {
            DropDownView.currentlyOpenDropdown = nil
        }
    }

    // MARK: - Public Functions

    /// 드롭다운 항목 갱신
    public func updateItems(_ newItems: [String]) {
        items = newItems
        dropdownTableView?.reloadData()
    }

    /// 버튼 타이틀 설정
    public func setTitle(_ title: String) {
        configureButton(title: title)
    }

    /// 현재 선택된 타이틀 반환
    public func getSelectedTitle() -> String? {
        if let attributed = button.configuration?.attributedTitle {
            return NSAttributedString(attributed).string
        }
        return nil
    }

    // MARK: - Private Helpers

    /// 버튼 스타일 설정
    private func configureButton(title: String) {
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer([
                .font: EATSSUDesignFontFamily.Pretendard.regular.font(size: 14),
                .foregroundColor: EATSSUDesignAsset.Color.GrayScale.gray700.color
            ])
        )
        config.baseBackgroundColor = EATSSUDesignAsset.Color.GrayScale.gray100.color
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 32)
        config.titleAlignment = .leading

        button.configuration = config
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = EATSSUDesignAsset.Color.GrayScale.gray300.color.cgColor
        button.contentHorizontalAlignment = .leading
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension DropDownView: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = items[indexPath.row]
        config.textProperties.color = EATSSUDesignAsset.Color.GrayScale.gray700.color
        config.textProperties.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 14)
        cell.contentConfiguration = config
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = items[indexPath.row]
        setTitle(selected)
        onSelectItem?(selected)
        toggleDropdown()
    }
}
