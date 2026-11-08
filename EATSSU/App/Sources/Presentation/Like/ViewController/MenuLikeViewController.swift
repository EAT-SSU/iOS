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

/// 메뉴 찜: 검색창 + "오늘 식단에서 찜하기" 카드 + 내가 찜한 메뉴
///
/// - 검색창에 포커스가 가면 카드와 찜 목록을 숨기고, 2글자 이상이면 검색 결과를 보여준다 (기능 명세)
/// - X나 포커스 해제로 검색을 끝내면 카드가 접힌 찜 목록으로 돌아온다
final class MenuLikeViewController: BaseViewController {

    // MARK: - Types

    private enum Mode {
        case favorites
        /// 검색창에 포커스만 있고 검색어가 2글자 미만. 키보드와 흰 화면만 보인다
        case searchIdle
        /// 검색 결과 표시 중. `didFail`이면 결과 없음 안내 대신 빈 화면 + 실패 토스트
        case search(keyword: String, menus: [MenuSearchDTO], didFail: Bool)

        var isFavorites: Bool {
            if case .favorites = self { return true }
            return false
        }
    }

    // MARK: - Constants

    /// 디자인(탭 밑줄 아래 기준): 검색창 top 24 · 좌우 24 · 카드는 검색창 아래 21
    /// 찜 목록: 제목 중심 카드 아래 28.5, 구분선 제목 중심 아래 23(좌우 26), 첫 행 제목 중심 아래 30
    /// 검색 결과: 첫 행 검색창 아래 15
    private enum Layout {
        static let searchBarTop: CGFloat = 24
        static let horizontalInset: CGFloat = 24
        static let cardTop: CGFloat = 21
        static let favoritesTitleCenterBelowCard: CGFloat = 28.5
        static let favoritesSeparatorBelowTitle: CGFloat = 23
        static let favoritesRowsBelowTitle: CGFloat = 30
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

    /// 오늘 식단에서 찜하기: 현재 식당·시간대와 그 메뉴
    private var todaySlot: TodayMenuSlot = .default
    private var todayMenus: [BriefMenus] = []
    /// 오늘 메뉴를 성공적으로 받아왔는지. 불러오는 중·실패 상태에서는 "메뉴 없음" 문구를 보여주지 않는다
    private var hasLoadedTodayMenus = false
    private var todayMenuGeneration = 0
    private var isSubmittingTodayMenus = false

    // MARK: - UI Components

    private let searchBar = MenuSearchBar()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyView = EmptyStateView()
    private let todayMenuCard = TodayMenuFavoriteCardView()
    private lazy var favoritesHeaderView = makeFavoritesHeaderView()
    private let favoritesTitleLabel = UILabel()
    private let favoritesSeparator = UIView()
    private let searchResultsHeaderView = UIView(
        frame: CGRect(x: 0, y: 0, width: 0, height: Layout.searchResultsTop)
    )
    private var emptyViewTopConstraint: Constraint?

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

        view.addSubviews(tableView, emptyView, searchBar)
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

        // 찜한 메뉴가 없을 때 안내 문구는 카드 아래 영역의 가운데 위쪽에 둔다
        emptyView.snp.makeConstraints {
            emptyViewTopConstraint = $0.top.equalTo(tableView).constraint
            $0.leading.trailing.bottom.equalToSuperview()
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

        todayMenuCard.onToggle = { [weak self] in
            guard let self else { return }
            self.setTodayMenuExpanded(!self.todayMenuCard.isExpanded)
        }
        todayMenuCard.onTapChange = { [weak self] in
            self?.presentSlotSheet()
        }
        todayMenuCard.onTapSubmit = { [weak self] in
            self?.submitTodayMenus()
        }
    }

    // MARK: - Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateFavoritesHeaderHeight()
    }

    // MARK: - Public

    /// 찜 목록을 다시 받고, 검색 중이면 같은 검색어로 다시 검색한다. 카드가 펼쳐져 있으면 오늘 메뉴도 다시 받는다
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
        if todayMenuCard.isExpanded {
            loadTodayMenus()
        }
    }

    // MARK: - Search

    @objc private func textDidChange() {
        let keyword = currentKeyword
        guard keyword.count >= MenuFavoriteManager.minimumKeywordLength else {
            // 2글자 미만: 진행 중인 검색 응답을 무시하고, 포커스 중이면 빈 화면·아니면 찜 목록으로 돌아간다
            searchGeneration += 1
            mode = searchBar.textField.isFirstResponder ? .searchIdle : .favorites
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

    /// 검색을 끝내고(X 또는 포커스 해제) 카드가 접힌 찜 목록으로 돌아간다
    private func finishSearch() {
        searchGeneration += 1
        searchBar.textField.text = nil
        mode = .favorites
        setTodayMenuExpanded(false)
    }

    // MARK: - Render

    private func render() {
        switch mode {
        case .favorites:
            let favorites = MenuFavoriteManager.shared.favorites
            let showsEmpty = MenuFavoriteManager.shared.hasLoaded && favorites.isEmpty
            // 찜이 없어도 카드는 보인다. 제목·구분선은 찜이 있을 때만
            favoritesTitleLabel.isHidden = favorites.isEmpty
            favoritesSeparator.isHidden = favorites.isEmpty
            setTableHeader(favoritesHeaderView)
            emptyView.configure(title: TextLiteral.Like.menuEmptyTitle, subtitle: TextLiteral.Like.menuEmptySubtitle)
            emptyView.isHidden = !showsEmpty
            tableView.isHidden = false
        case .searchIdle:
            setTableHeader(searchResultsHeaderView)
            emptyView.isHidden = true
            tableView.isHidden = true
        case .search(_, let menus, let didFail):
            setTableHeader(searchResultsHeaderView)
            emptyView.configure(
                title: TextLiteral.Like.menuSearchEmptyTitle,
                subtitle: TextLiteral.Like.menuSearchEmptySubtitle
            )
            emptyView.isHidden = !(menus.isEmpty && !didFail)
            // 안내 문구는 흰 배경 테이블 뒤에 있으므로, 보일 때는 테이블을 숨긴다 (제휴 찜 목록과 같은 방식)
            tableView.isHidden = !emptyView.isHidden
        }
        emptyViewTopConstraint?.update(offset: mode.isFavorites ? favoritesHeaderView.bounds.height : 0)
        tableView.reloadData()
        updateFavoritesHeaderHeight()
    }

    private func setTableHeader(_ header: UIView?) {
        guard tableView.tableHeaderView !== header else { return }
        tableView.tableHeaderView = header
    }

    /// 카드가 접히거나 펼쳐지고 칩 줄 수가 바뀌면 헤더 높이가 달라지므로 다시 계산해 테이블에 반영한다
    private func updateFavoritesHeaderHeight() {
        guard tableView.tableHeaderView === favoritesHeaderView, tableView.bounds.width > 0 else { return }
        let width = tableView.bounds.width
        // 칩 줄 수는 폭에 따라 달라지고 칩 높이는 레이아웃 때 계산되므로, 폭을 맞춰 한 번 레이아웃한 뒤 높이를 잰다
        favoritesHeaderView.frame.size.width = width
        favoritesHeaderView.layoutIfNeeded()
        let target = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let height = favoritesHeaderView.systemLayoutSizeFitting(
            target,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        guard abs(favoritesHeaderView.bounds.height - height) > 0.5 else { return }
        favoritesHeaderView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        tableView.tableHeaderView = favoritesHeaderView
        emptyViewTopConstraint?.update(offset: height)
    }

    private func makeFavoritesHeaderView() -> UIView {
        let header = UIView()

        favoritesTitleLabel.text = TextLiteral.Like.menuListTitle
        favoritesTitleLabel.font = .subtitle2
        favoritesTitleLabel.textColor = .gray700

        favoritesSeparator.backgroundColor = .gray200

        header.addSubviews(todayMenuCard, favoritesTitleLabel, favoritesSeparator)
        todayMenuCard.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.cardTop)
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
        }
        favoritesTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Layout.favoritesInset)
            $0.centerY.equalTo(todayMenuCard.snp.bottom).offset(Layout.favoritesTitleCenterBelowCard)
        }
        favoritesSeparator.snp.makeConstraints {
            $0.top.equalTo(favoritesTitleLabel.snp.centerY).offset(Layout.favoritesSeparatorBelowTitle)
            $0.leading.trailing.equalToSuperview().inset(Layout.favoritesInset)
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview().inset(Layout.favoritesRowsBelowTitle - Layout.favoritesSeparatorBelowTitle - 1)
        }
        todayMenuCard.setExpanded(false)
        return header
    }

    // MARK: - Today Menu

    private func setTodayMenuExpanded(_ expanded: Bool) {
        todayMenuCard.setExpanded(expanded)
        if expanded {
            renderTodayMenuCard()
            loadTodayMenus()
        }
        render()
    }

    private func loadTodayMenus() {
        todayMenuGeneration += 1
        let generation = todayMenuGeneration
        let slot = todaySlot
        hasLoadedTodayMenus = false
        NetworkService.shared.request(
            HomeRouter.getChangeMenuTableResponse(
                date: DateFormatter.serverDay.string(from: Date()),
                restaurant: slot.restaurant.identifier,
                time: slot.mealTime.rawValue,
                language: ChangeMenuTableResponse.mealLanguageParameter
            ),
            responseType: [ChangeMenuTableResponse].self
        ) { [weak self] result in
            guard let self, generation == self.todayMenuGeneration, slot == self.todaySlot else { return }
            switch result {
            case .success(let meals):
                // 학식 탭과 같은 메뉴를 보여준다(영어면 번역된 대표메뉴만). 한 시간대에 식단이 여러 개여도 메뉴는 한 번씩만
                var seen = Set<Int>()
                self.todayMenus = meals.flatMap(\.displayMenus).filter { !$0.name.isEmpty && seen.insert($0.menuId).inserted }
                self.hasLoadedTodayMenus = true
            case .failure(let error):
                print("오늘 식단 조회 실패 \(slot.restaurant.identifier)/\(slot.mealTime.rawValue): \(error.localizedDescription)")
                self.todayMenus = []
                self.showToast(message: TextLiteral.Like.menuLoadFailed, type: .danger)
            }
            self.renderTodayMenuCard()
            self.render()
        }
    }

    private func renderTodayMenuCard(selectedIds: Set<Int>? = nil) {
        let favoriteIds = Set(MenuFavoriteManager.shared.favorites.map(\.menuId))
        let items = todayMenus.map {
            MenuChipFlowView.Item(id: $0.menuId, title: $0.name, isLocked: favoriteIds.contains($0.menuId))
        }
        todayMenuCard.configure(
            slot: todaySlot,
            items: items,
            selectedIds: selectedIds ?? todayMenuCard.selectedIds,
            showsNoMenu: hasLoadedTodayMenus
        )
    }

    private func presentSlotSheet() {
        let sheet = TodayMenuSlotSheetViewController(currentSlot: todaySlot)
        sheet.onApply = { [weak self] slot in
            guard let self else { return }
            self.todaySlot = slot
            self.todayMenus = []
            self.todayMenuCard.clearSelection()
            self.renderTodayMenuCard()
            self.loadTodayMenus()
        }
        present(sheet, animated: true)
    }

    /// 선택한 메뉴를 한 번에 찜한다. 이미 찜한 메뉴는 칩에서 고를 수 없으므로 새 메뉴만 서버로 간다
    ///
    /// 다른 곳(검색 결과 하트)에서 요청이 진행 중인 메뉴는 `setFavorite`가 completion 없이 돌아오므로 이번 제출에서 뺀다.
    /// 실패한 메뉴는 선택을 남겨 두어 사용자가 다시 시도할 수 있게 한다
    private func submitTodayMenus() {
        guard !isSubmittingTodayMenus else { return }
        let manager = MenuFavoriteManager.shared
        let selected = todayMenus.filter {
            todayMenuCard.selectedIds.contains($0.menuId) && !manager.isPending(menuId: $0.menuId)
        }
        guard !selected.isEmpty else { return }
        isSubmittingTodayMenus = true

        let restaurant = todaySlot.restaurant.identifier
        let group = DispatchGroup()
        var failedIds = Set<Int>()
        for menu in selected {
            group.enter()
            manager.setFavorite(true, menuId: menu.menuId, menuName: menu.name, restaurant: restaurant) { result in
                if case .failure(let error) = result {
                    failedIds.insert(menu.menuId)
                    print("오늘 식단 찜 실패 menuId=\(menu.menuId): \(error.localizedDescription)")
                }
                group.leave()
            }
        }
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.isSubmittingTodayMenus = false
            self.renderTodayMenuCard(selectedIds: failedIds)
            self.render()
            if failedIds.isEmpty {
                self.showToast(message: TextLiteral.Like.menuAddedToast, type: .success)
            } else {
                self.showToast(message: TextLiteral.Like.menuUpdateFailed, type: .danger)
            }
        }
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
        case .searchIdle:
            return
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
                // 찜 목록에서 해제한 메뉴는 목록에서 바로 사라지고, 카드의 잠긴 칩도 풀린다
                self.renderTodayMenuCard()
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
        case .searchIdle:
            0
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
            cell.configure(
                name: menu.menuName,
                restaurant: restaurantTitle(for: menu.restaurant),
                isFavorite: true,
                style: .favorite
            )
        case .search(let keyword, let menus, _):
            let menu = menus[indexPath.row]
            cell.configure(
                name: menu.menuName,
                restaurant: restaurantTitle(for: menu.restaurant),
                isFavorite: MenuFavoriteManager.shared.isFavorite(menu),
                style: .search(keyword: keyword)
            )
        case .searchIdle:
            break
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

    func textFieldDidBeginEditing(_ textField: UITextField) {
        // 포커스가 가면 카드와 찜 목록을 숨긴다. 검색어가 이미 2글자 이상이면 결과는 그대로 둔다
        if currentKeyword.count < MenuFavoriteManager.minimumKeywordLength {
            mode = .searchIdle
            render()
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        // 결과가 떠 있으면 유지하고, 검색어가 짧으면 찜 목록으로 돌아간다
        if currentKeyword.count < MenuFavoriteManager.minimumKeywordLength {
            finishSearch()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 1글자로 검색을 시도하면 2글자부터 검색된다는 것을 알린다 (빈 검색어는 키보드만 내린다)
        let length = currentKeyword.count
        if length > 0, length < MenuFavoriteManager.minimumKeywordLength {
            showToast(message: TextLiteral.Like.menuSearchTooShort, type: .danger)
        }
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        // X: 검색을 끝내고 이전 화면(카드가 접힌 찜 목록)으로 돌아간다
        textField.resignFirstResponder()
        finishSearch()
        return false
    }
}
