//
//  MenuLikeViewController.swift
//  EATSSU
//
//  Created by 황상환 on 10/6/26.
//

import Combine
import UIKit

import SnapKit

import EATSSUDesign

/// 메뉴 찜: 검색창 + (검색어 2글자 미만) 내가 찜한 메뉴 / (2글자 이상) 검색 결과
final class MenuLikeViewController: BaseViewController {

    // MARK: - Types

    private enum Mode {
        case favorites
        /// 검색 결과 표시 중. `didFail`이면 결과 없음 안내 대신 빈 화면 + 실패 토스트
        case search(keyword: String, menus: [MenuSearchDTO], didFail: Bool)
    }

    // MARK: - Constants

    /// 디자인(탭 밑줄 아래 기준): 검색창 top 24 · 좌우 24
    /// 찜 목록: 제목 중심 검색창 아래 34, 구분선 검색창 아래 57(좌우 26), 첫 행 검색창 아래 64
    /// 검색 결과: 첫 행 검색창 아래 15
    private enum Layout {
        static let searchBarTop: CGFloat = 24
        static let horizontalInset: CGFloat = 24
        static let favoritesHeaderHeight: CGFloat = 64
        static let favoritesTitleCenterY: CGFloat = 34
        static let favoritesSeparatorTop: CGFloat = 57
        static let favoritesInset: CGFloat = 26
        static let searchResultsTop: CGFloat = 15
    }

    // MARK: - Properties

    private var mode: Mode = .favorites
    private let keywordSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()

    /// 검색 요청마다 증가. 검색어를 바꾼 뒤 도착한 이전 검색 응답을 버린다
    private var searchGeneration = 0

    private var currentKeyword: String {
        (searchBar.textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - UI Components

    private let searchBar = MenuSearchBar()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyView = EmptyStateView()
    private lazy var favoritesHeaderView = makeFavoritesHeaderView()
    private let searchResultsHeaderView = UIView(
        frame: CGRect(x: 0, y: 0, width: 0, height: Layout.searchResultsTop)
    )

    // MARK: - View Setup

    override func configureUI() {
        view.backgroundColor = .white

        tableView.register(MenuFavoriteCell.self, forCellReuseIdentifier: MenuFavoriteCell.identifier)
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 36
        tableView.showsVerticalScrollIndicator = false
        tableView.keyboardDismissMode = .onDrag
        tableView.tableFooterView = UIView()

        emptyView.isHidden = true
        emptyView.isUserInteractionEnabled = false

        searchBar.textField.delegate = self

        // 빈 영역을 누르면 키보드를 내린다 (하트 등 버튼 터치는 그대로 전달)
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        view.addSubviews(emptyView, tableView, searchBar)
    }

    override func setLayout() {
        searchBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.searchBarTop)
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        // 디자인의 안내 문구 위치는 탭 밑줄 아래 전체 영역 기준 약 45% 지점
        emptyView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func setButtonEvent() {
        searchBar.textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)

        keywordSubject
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] keyword in
                // 디바운스 사이에 검색어가 바뀌었으면(2글자 미만으로 지운 경우 포함) 검색하지 않는다
                guard let self, keyword == self.currentKeyword else { return }
                self.search(keyword: keyword)
            }
            .store(in: &cancellables)
    }

    // MARK: - Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    // MARK: - Public

    /// 찜 목록을 다시 받고, 검색 중이면 같은 검색어로 다시 검색한다
    func reload() {
        render()
        MenuFavoriteManager.shared.refresh { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.render()
            case .failure(let error):
                print("메뉴 찜 목록 조회 실패: \(error.localizedDescription)")
                if !MenuFavoriteManager.shared.hasLoaded {
                    self.showToast(message: TextLiteral.Like.menuLoadFailed, type: .danger)
                }
            }
        }
        if case .search(let keyword, _, _) = mode, keyword == currentKeyword {
            search(keyword: keyword)
        }
    }

    // MARK: - Search

    @objc private func textDidChange() {
        let keyword = currentKeyword
        guard keyword.count >= MenuFavoriteManager.minimumKeywordLength else {
            // 2글자 미만: 진행 중인 검색 응답을 무시하고 바로 찜 목록으로 돌아간다
            searchGeneration += 1
            mode = .favorites
            render()
            return
        }
        keywordSubject.send(keyword)
    }

    private func search(keyword: String) {
        searchGeneration += 1
        let generation = searchGeneration
        MenuFavoriteManager.shared.search(keyword: keyword) { [weak self] result in
            guard let self, generation == self.searchGeneration, keyword == self.currentKeyword else { return }
            switch result {
            case .success(let menus):
                self.mode = .search(keyword: keyword, menus: menus, didFail: false)
            case .failure(let error):
                print("메뉴 검색 실패: \(error.localizedDescription)")
                self.mode = .search(keyword: keyword, menus: [], didFail: true)
                self.showToast(message: TextLiteral.Like.menuLoadFailed, type: .danger)
            }
            self.render()
        }
    }

    // MARK: - Render

    private func render() {
        switch mode {
        case .favorites:
            let favorites = MenuFavoriteManager.shared.favorites
            let showsEmpty = MenuFavoriteManager.shared.hasLoaded && favorites.isEmpty
            setTableHeader(favorites.isEmpty ? nil : favoritesHeaderView)
            emptyView.configure(title: TextLiteral.Like.menuEmptyTitle, subtitle: TextLiteral.Like.menuEmptySubtitle)
            emptyView.isHidden = !showsEmpty
        case .search(_, let menus, let didFail):
            setTableHeader(searchResultsHeaderView)
            emptyView.configure(
                title: TextLiteral.Like.menuSearchEmptyTitle,
                subtitle: TextLiteral.Like.menuSearchEmptySubtitle
            )
            emptyView.isHidden = !(menus.isEmpty && !didFail)
        }
        tableView.reloadData()
    }

    private func setTableHeader(_ header: UIView?) {
        guard tableView.tableHeaderView !== header else { return }
        tableView.tableHeaderView = header
    }

    private func makeFavoritesHeaderView() -> UIView {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Layout.favoritesHeaderHeight))

        let titleLabel = UILabel()
        titleLabel.text = TextLiteral.Like.menuListTitle
        titleLabel.font = .subtitle2
        titleLabel.textColor = .gray700

        let separator = UIView()
        separator.backgroundColor = .gray200

        header.addSubviews(titleLabel, separator)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Layout.favoritesInset)
            $0.centerY.equalTo(header.snp.top).offset(Layout.favoritesTitleCenterY)
        }
        separator.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.favoritesSeparatorTop)
            $0.leading.trailing.equalToSuperview().inset(Layout.favoritesInset)
            $0.height.equalTo(1)
        }
        return header
    }

    // MARK: - Favorite

    private func toggleFavorite(at indexPath: IndexPath) {
        let manager = MenuFavoriteManager.shared
        let item: (menuId: Int, menuName: String, restaurant: String, toBe: Bool)
        switch mode {
        case .favorites:
            guard manager.favorites.indices.contains(indexPath.row) else { return }
            let menu = manager.favorites[indexPath.row]
            item = (menu.menuId, menu.menuName, menu.restaurant, false)
        case .search(_, let menus, _):
            guard menus.indices.contains(indexPath.row) else { return }
            let menu = menus[indexPath.row]
            item = (menu.menuId, menu.menuName, menu.restaurant, !manager.isFavorite(menu))
        }
        guard !manager.isPending(menuId: item.menuId) else { return }

        manager.setFavorite(
            item.toBe,
            menuId: item.menuId,
            menuName: item.menuName,
            restaurant: item.restaurant
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                // 찜 목록에서 해제한 메뉴는 목록에서 바로 사라진다
                self.render()
                self.showToast(
                    message: item.toBe ? TextLiteral.Like.menuAddedToast : TextLiteral.Like.menuRemovedToast,
                    type: .success
                )
            case .failure(let error):
                print("메뉴 찜 변경 실패 menuId=\(item.menuId): \(error.localizedDescription)")
                self.showToast(message: TextLiteral.Like.menuUpdateFailed, type: .danger)
            }
        }
    }

    /// 서버 식당 코드 → 현재 언어의 식당 이름. 앱에 없는 식당(FOOD_COURT 등)은 표시하지 않는다
    private func restaurantTitle(for code: String) -> String? {
        Restaurant.allCases.first { $0.identifier == code }?.title
    }
}

// MARK: - UITableViewDataSource

extension MenuLikeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case .favorites:
            MenuFavoriteManager.shared.favorites.count
        case .search(_, let menus, _):
            menus.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MenuFavoriteCell.identifier,
            for: indexPath
        ) as? MenuFavoriteCell else { return UITableViewCell() }

        switch mode {
        case .favorites:
            let menu = MenuFavoriteManager.shared.favorites[indexPath.row]
            cell.configure(name: menu.menuName, restaurant: nil, isFavorite: true, style: .favorite)
        case .search(let keyword, let menus, _):
            let menu = menus[indexPath.row]
            cell.configure(
                name: menu.menuName,
                restaurant: restaurantTitle(for: menu.restaurant),
                isFavorite: MenuFavoriteManager.shared.isFavorite(menu),
                style: .search(keyword: keyword)
            )
        }
        cell.onTapHeart = { [weak self, weak cell, weak tableView] in
            guard let self, let cell, let indexPath = tableView?.indexPath(for: cell) else { return }
            self.toggleFavorite(at: indexPath)
        }
        return cell
    }
}

// MARK: - UITextFieldDelegate

extension MenuLikeViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        // X 버튼으로 지운 경우에도 editingChanged와 같은 흐름을 타도록 지워진 뒤 반영한다
        DispatchQueue.main.async { [weak self] in
            self?.textDidChange()
        }
        return true
    }
}
