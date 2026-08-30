//
//  LikedPartnershipViewController.swift
//  EATSSU
//
//  Created by 황상환 on 8/30/26.
//

import UIKit

import SnapKit

import EATSSUDesign

/// 제휴 찜 목록: 업종 필터 · 편집 진입 · 스와이프 삭제(취소하기) · 상세 진입
final class LikedPartnershipViewController: BaseViewController {

    // MARK: - Constants

    /// 디자인: 탭 밑줄과 칩 사이 12, 좌우 24, 칩과 첫 행 사이 7
    private enum Layout {
        static let chipBarTop: CGFloat = 12
        static let horizontalInset: CGFloat = 24
        static let listTop: CGFloat = 7
    }

    /// 찜 목록 필터 (축제 제외)
    private static let filters: [PartnershipFilter] = PartnershipFilter.allCases.filter { $0 != .festival }

    // MARK: - Properties

    private var stores: [PartnershipDTO] = []
    private var filter: PartnershipFilter = .all

    private var displayedStores: [PartnershipDTO] {
        guard let type = filter.restaurantType else { return stores }
        return stores.filter { $0.restaurantType == type }
    }

    // MARK: - UI Components

    private let filterChipBar = FilterChipBar()
    private let editButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyView = EmptyStateView()

    // MARK: - View Setup

    override func configureUI() {
        view.backgroundColor = .white

        filterChipBar.horizontalInset = Layout.horizontalInset
        filterChipBar.configure(titles: Self.filters.map { $0.title })

        editButton.setTitle(TextLiteral.Like.edit, for: .normal)
        editButton.titleLabel?.font = .body2
        editButton.setTitleColor(.gray500, for: .normal)

        tableView.register(LikedPartnershipCell.self, forCellReuseIdentifier: LikedPartnershipCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: Layout.horizontalInset, bottom: 0, right: Layout.horizontalInset)
        tableView.separatorColor = .gray100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 77
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false

        emptyView.configure(title: TextLiteral.Like.emptyTitle, subtitle: TextLiteral.Like.emptySubtitle)
        emptyView.isHidden = true

        view.addSubviews(filterChipBar, editButton, tableView, emptyView)
    }

    override func setLayout() {
        filterChipBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.chipBarTop)
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(editButton.snp.leading).offset(-8)
        }

        editButton.snp.makeConstraints {
            $0.centerY.equalTo(filterChipBar)
            $0.trailing.equalToSuperview().inset(Layout.horizontalInset)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(filterChipBar.snp.bottom).offset(Layout.listTop)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        emptyView.snp.makeConstraints {
            $0.edges.equalTo(tableView)
        }
    }

    override func setButtonEvent() {
        filterChipBar.onSelect = { [weak self] index in
            guard let self, Self.filters.indices.contains(index) else { return }
            self.filter = Self.filters[index]
            self.tableView.reloadData()
            self.updateEmptyState()
        }
        editButton.addTarget(self, action: #selector(didTapEdit), for: .touchUpInside)
    }

    // MARK: - Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    // MARK: - Public

    /// 서버에서 찜 목록을 다시 받아 표시. 실패 시 마지막으로 받아둔 목록을 유지한다
    func reload() {
        applyStores(PartnershipLikeManager.shared.likedStores)
        PartnershipLikeManager.shared.refresh { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let stores):
                self.applyStores(stores)
            case .failure(let error):
                print("찜 목록 조회 실패: \(error.localizedDescription)")
                if !PartnershipLikeManager.shared.hasLoaded {
                    self.showToast(message: TextLiteral.Like.loadFailed, type: .danger)
                }
            }
        }
    }

    /// 편집 모드 삭제 후 복귀: 어떤 필터에 있었든 '전체'로 돌아온다
    func resetFilterToAll() {
        filter = .all
        filterChipBar.select(index: 0, animated: false)
    }

    // MARK: - Private

    private func applyStores(_ stores: [PartnershipDTO]) {
        self.stores = stores
        tableView.reloadData()
        updateEmptyState()
    }

    private func updateEmptyState() {
        let isEmpty = displayedStores.isEmpty
        emptyView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        editButton.isEnabled = !stores.isEmpty
        editButton.alpha = stores.isEmpty ? 0.4 : 1
    }

    /// 스와이프 삭제: 목록에서 즉시 제거하고 서버 반영, 토스트의 '취소하기'로 되돌릴 수 있다
    private func removeStore(_ store: PartnershipDTO) {
        stores.removeAll { $0.storeKey == store.storeKey }
        tableView.reloadData()
        updateEmptyState()

        PartnershipLikeManager.shared.setLiked(false, store: store) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.showToast(
                    message: TextLiteral.Like.removedToast,
                    type: .success,
                    actionTitle: TextLiteral.Like.undo
                ) { [weak self] in
                    self?.restoreStore(store)
                }
            case .failure:
                self.applyStores(PartnershipLikeManager.shared.likedStores)
                self.showToast(message: TextLiteral.Like.updateFailed, type: .danger)
            }
        }
    }

    /// '취소하기': 찜을 다시 등록하고 목록 맨 위로 되돌린다
    private func restoreStore(_ store: PartnershipDTO) {
        PartnershipLikeManager.shared.setLiked(true, store: store) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.applyStores(PartnershipLikeManager.shared.likedStores)
            case .failure:
                self.showToast(message: TextLiteral.Like.updateFailed, type: .danger)
            }
        }
    }

    /// 지도 탭으로 전환해 해당 업체 시트를 띄운다. 지도의 뒤로가기로 이 화면에 복귀
    private func showDetail(for store: PartnershipDTO) {
        (tabBarController as? CustomTabBarContainerController)?.showPartnershipDetailOnMap(store)
    }

    // MARK: - Actions

    @objc private func didTapEdit() {
        let editVC = LikedPartnershipEditViewController(stores: stores)
        editVC.onDidDelete = { [weak self] in
            guard let self else { return }
            self.resetFilterToAll()
            self.applyStores(PartnershipLikeManager.shared.likedStores)
            self.showToast(message: TextLiteral.Like.removedToast, type: .success)
        }
        navigationController?.pushViewController(editVC, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension LikedPartnershipViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedStores.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: LikedPartnershipCell.identifier,
            for: indexPath
        ) as? LikedPartnershipCell else { return UITableViewCell() }
        cell.configure(store: displayedStores[indexPath.row], mode: .normal)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension LikedPartnershipViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showDetail(for: displayedStores[indexPath.row])
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let store = displayedStores[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            self?.removeStore(store)
            completion(true)
        }
        delete.backgroundColor = .white
        delete.image = Self.deleteActionImage
        let configuration = UISwipeActionsConfiguration(actions: [delete])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    /// 빨간 원(36, danger) 안에 흰 휴지통 (디자인의 스와이프 삭제 아이콘)
    private static let deleteActionImage: UIImage = {
        let size = CGSize(width: 36, height: 36)
        let icon = EATSSUDesignAsset.Images.icDelete.image.withTintColor(.white, renderingMode: .alwaysOriginal)
        return UIGraphicsImageRenderer(size: size).image { context in
            UIColor.danger.setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
            let iconSize = CGSize(width: 20, height: 20)
            icon.draw(in: CGRect(
                origin: CGPoint(x: (size.width - iconSize.width) / 2, y: (size.height - iconSize.height) / 2),
                size: iconSize
            ))
        }.withRenderingMode(.alwaysOriginal)
    }()
}
