//
//  DropDownView.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 6/25/25.
//

import UIKit

import EATSSUDesign

import SnapKit

final class DropDownView: UIView {

    // MARK: - Properties

    private var items: [String]
    public var onSelectItem: ((String) -> Void)?
    private var isDropdownVisible = false
    private var dropdownTableView: UITableView?

    // MARK: - UI Components

    private let button = UIButton(type: .system)
    private let arrow = UIImageView(image: UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate))

    // MARK: - Init

    init(title: String, items: [String]) {
        self.items = items
        super.init(frame: .zero)
        setupButton(title: title)
        setupLayout()
        setupAction()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Setup

    private func setupButton(title: String) {
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

    private func setupLayout() {
        addSubviews(button, arrow)

        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        arrow.snp.makeConstraints {
            $0.centerY.equalTo(button)
            $0.trailing.equalToSuperview().inset(12)
            $0.width.height.equalTo(16)
        }

        arrow.tintColor = EATSSUDesignAsset.Color.GrayScale.gray700.color
    }

    private func setupAction() {
        button.addTarget(self, action: #selector(toggleDropdown), for: .touchUpInside)
    }

    // MARK: - Dropdown

    @objc private func toggleDropdown() {
        guard let parentView = self.window else { return }

        if isDropdownVisible {
            dropdownTableView?.removeFromSuperview()
            dropdownTableView = nil
        } else {
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

            let origin = self.convert(self.bounds.origin, to: parentView)
            tableView.snp.makeConstraints {
                $0.top.equalTo(origin.y + 48 + 6)
                $0.leading.equalTo(origin.x)
                $0.width.equalTo(self.bounds.width)
                $0.height.equalTo(min(items.count * 44, 200))
            }

            dropdownTableView = tableView
        }

        isDropdownVisible.toggle()
    }

    // MARK: - Public

    public func updateItems(_ newItems: [String]) {
        items = newItems
        dropdownTableView?.reloadData()
    }

    public func setTitle(_ title: String) {
        var config = button.configuration
        config?.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer([
                .font: EATSSUDesignFontFamily.Pretendard.regular.font(size: 14),
                .foregroundColor: EATSSUDesignAsset.Color.GrayScale.gray700.color
            ])
        )
        config?.titleAlignment = .leading
        button.configuration = config
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
