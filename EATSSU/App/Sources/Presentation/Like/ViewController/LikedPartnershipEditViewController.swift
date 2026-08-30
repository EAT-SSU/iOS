//
//  LikedPartnershipEditViewController.swift
//  EATSSU
//
//  Created by 황상환 on 8/30/26.
//

import UIKit

import SnapKit

import EATSSUDesign

/// 제휴 찜 편집 모드: 전체/개별 선택 후 일괄 삭제. 필터는 제공하지 않는다
final class LikedPartnershipEditViewController: BaseViewController {

    // MARK: - Constants

    private enum Layout {
        static let horizontalInset: CGFloat = 20
        static let headerHeight: CGFloat = 56
    }

    // MARK: - Properties

    override var shouldHideTabBar: Bool { true }

    private let stores: [PartnershipDTO]
    private var selectedKeys: Set<String> = []

    /// 삭제가 서버에 반영된 뒤 호출. 호출 시점에 이미 이전 화면으로 돌아가 있다
    var onDidDelete: (() -> Void)?

    private var isAllSelected: Bool {
        !stores.isEmpty && selectedKeys.count == stores.count
    }

    // MARK: - UI Components

    private let selectAllButton = UIButton(type: .system)
    private let headerSeparator = UIView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let deleteButton = MainButton()

    // MARK: - Init

    init(stores: [PartnershipDTO]) {
        self.stores = stores
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Setup

    override func configureUI() {
        view.backgroundColor = .white

        var config = UIButton.Configuration.plain()
        config.image = EATSSUDesignAsset.Images.icUncheck.image
        config.imagePadding = 12
        config.baseForegroundColor = .label
        config.contentInsets = .zero
        config.attributedTitle = AttributedString(
            TextLiteral.Like.selectAll,
            attributes: AttributeContainer([.font: UIFont.subtitle1])
        )
        selectAllButton.configuration = config
        selectAllButton.contentHorizontalAlignment = .leading

        headerSeparator.backgroundColor = .gray200

        tableView.register(LikedPartnershipCell.self, forCellReuseIdentifier: LikedPartnershipCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: Layout.horizontalInset, bottom: 0, right: Layout.horizontalInset)
        tableView.separatorColor = .gray200
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 84
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false

        deleteButton.title = TextLiteral.Like.delete
        updateDeleteButton()

        view.addSubviews(selectAllButton, headerSeparator, tableView, deleteButton)
    }

    override func setLayout() {
        selectAllButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.height.equalTo(Layout.headerHeight)
        }

        headerSeparator.snp.makeConstraints {
            $0.top.equalTo(selectAllButton.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }

        deleteButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(12)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(headerSeparator.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(deleteButton.snp.top).offset(-12)
        }
    }

    override func setButtonEvent() {
        selectAllButton.addTarget(self, action: #selector(didTapSelectAll), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
    }

    override func setCustomNavigationBar() {
        super.setCustomNavigationBar()
        navigationItem.title = TextLiteral.Like.title
        navigationItem.hidesBackButton = true
        // 선택 중이어도 확인 없이 즉시 닫는다 (기획)
        let closeItem = UIBarButtonItem(
            image: EATSSUDesignAsset.Images.icClose.image.resize(newWidth: 24),
            style: .plain,
            target: self,
            action: #selector(didTapClose)
        )
        closeItem.tintColor = .gray500
        navigationItem.rightBarButtonItem = closeItem
    }

    // MARK: - Private

    private func updateDeleteButton() {
        let count = selectedKeys.count
        deleteButton.title = count == 0 ? TextLiteral.Like.delete : TextLiteral.Like.deleteCount(count)
        deleteButton.isEnabled = count > 0
        deleteButton.backgroundColor = count > 0 ? .danger : .gray300
    }

    private func updateSelectAllButton() {
        selectAllButton.configuration?.image = isAllSelected
            ? EATSSUDesignAsset.Images.icCheck.image
            : EATSSUDesignAsset.Images.icUncheck.image
    }

    // MARK: - Actions

    @objc private func didTapSelectAll() {
        selectedKeys = isAllSelected ? [] : Set(stores.map(\.storeKey))
        tableView.reloadData()
        updateSelectAllButton()
        updateDeleteButton()
    }

    @objc private func didTapClose() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapDelete() {
        let targets = stores.filter { selectedKeys.contains($0.storeKey) }
        guard !targets.isEmpty else { return }
        deleteButton.isEnabled = false

        PartnershipLikeManager.shared.removeLikes(stores: targets) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.navigationController?.popViewController(animated: true)
                self.onDidDelete?()
            case .failure:
                self.deleteButton.isEnabled = true
                self.showToast(message: TextLiteral.Like.updateFailed, type: .danger)
            }
        }
    }
}

// MARK: - UITableViewDataSource / Delegate

extension LikedPartnershipEditViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        stores.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: LikedPartnershipCell.identifier,
            for: indexPath
        ) as? LikedPartnershipCell else { return UITableViewCell() }
        let store = stores[indexPath.row]
        cell.configure(store: store, mode: .editing(isSelected: selectedKeys.contains(store.storeKey)))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = stores[indexPath.row].storeKey
        if selectedKeys.contains(key) { selectedKeys.remove(key) } else { selectedKeys.insert(key) }
        tableView.reloadRows(at: [indexPath], with: .none)
        updateSelectAllButton()
        updateDeleteButton()
    }
}
