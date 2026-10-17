//
//  MenuFavoriteManager.swift
//  EATSSU
//
//  Created by 황상환 on 10/6/26.
//

import Foundation

/// 메뉴 찜 상태의 앱 내 단일 소스
///
/// - 찜 목록은 서버가 최근 찜한 순으로 내려주므로 순서를 로컬에 따로 기록하지 않는다.
/// - 검색 결과의 찜 여부는 응답의 `isFavorite`를 쓰되, 이 세션에서 바꾼 메뉴는 바꾼 값을 우선한다.
///   (토글 전에 시작된 검색 응답이 늦게 도착해도 하트가 되돌아가지 않게 한다)
final class MenuFavoriteManager {

    // MARK: - Singleton

    static let shared = MenuFavoriteManager()

    private init() {}

    // MARK: - Constants

    /// 서버 검색 최소 글자 수 (앞뒤 공백 제거 기준). 미만이면 서버가 400(40025)을 반환한다
    static let minimumKeywordLength = 2

    // MARK: - State

    /// 마지막으로 받아온 찜 목록 (최근 찜한 순)
    private(set) var favorites: [FavoriteMenuDTO] = []

    /// 찜 목록을 한 번이라도 서버에서 받아왔는지
    private(set) var hasLoaded = false

    /// 이 세션에서 찜·해제에 성공한 메뉴의 최신 상태
    private var toggledStates: [Int: Bool] = [:]

    /// 요청 중인 메뉴. 같은 하트를 연타해 요청이 겹치지 않게 한다
    private var pendingMenuIds: Set<Int> = []

    /// 찜 상태가 바뀔 때마다 증가. 변경 이전에 시작된 목록 조회 응답이 최신 로컬 상태를 덮어쓰지 않게 한다
    private var stateVersion = 0

    /// `reset()`마다 증가. 초기화 전에 시작된 찜 요청의 응답이 다음 계정의 상태에 반영되지 않게 한다
    private var sessionVersion = 0

    /// 로그아웃·탈퇴·세션 만료 시 호출. 다른 계정의 찜 상태가 남지 않게 비운다
    func reset() {
        favorites = []
        hasLoaded = false
        toggledStates = [:]
        pendingMenuIds = []
        stateVersion += 1
        sessionVersion += 1
    }

    // MARK: - Query

    func isFavorite(_ menu: MenuSearchDTO) -> Bool {
        toggledStates[menu.menuId] ?? menu.isFavorite
    }

    func isPending(menuId: Int) -> Bool {
        pendingMenuIds.contains(menuId)
    }

    // MARK: - Fetch

    /// 찜 목록을 서버에서 받아 상태를 갱신한다
    func refresh(completion: @escaping (Result<[FavoriteMenuDTO], Error>) -> Void) {
        let version = stateVersion
        NetworkService.shared.request(
            MenuFavoriteRouter.getFavorites,
            responseType: [FavoriteMenuDTO].self,
            useAuth: true
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let favorites):
                // 조회 중에 찜 상태가 바뀌었으면 이 응답은 이미 낡은 것이므로 로컬 상태를 유지한다
                guard version == self.stateVersion else {
                    completion(.success(self.favorites))
                    return
                }
                self.favorites = favorites
                self.toggledStates = [:]
                self.hasLoaded = true
                completion(.success(favorites))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// 메뉴 검색. 결과는 화면 표시 순서(`sortedForDisplay`)로 정렬해 돌려준다
    func search(keyword: String, completion: @escaping (Result<[MenuSearchDTO], Error>) -> Void) {
        NetworkService.shared.request(
            MenuFavoriteRouter.search(keyword: keyword),
            responseType: [MenuSearchDTO].self,
            useAuth: true
        ) { result in
            completion(result.map { Self.sortedForDisplay($0, keyword: keyword) })
        }
    }

    // MARK: - Update

    /// 찜·해제. 서버 성공 후 로컬 상태(목록, 세션 상태)를 반영한다
    func setFavorite(
        _ isFavorite: Bool,
        menuId: Int,
        menuName: String,
        restaurant: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard !pendingMenuIds.contains(menuId) else { return }
        pendingMenuIds.insert(menuId)

        let session = sessionVersion
        let target: MenuFavoriteRouter = isFavorite ? .add(menuId: menuId) : .remove(menuId: menuId)
        NetworkService.shared.request(target, responseType: Bool.self, useAuth: true) { [weak self] result in
            // 요청 중에 로그아웃 등으로 초기화됐으면 이전 계정의 응답이므로 버린다
            guard let self, session == self.sessionVersion else { return }
            self.pendingMenuIds.remove(menuId)
            switch result {
            case .success:
                // 서버 변경이 성공한 시점에 버전을 올린다. 실패한 요청은 진행 중인 목록 조회를 무효화하지 않는다
                self.stateVersion += 1
                self.toggledStates[menuId] = isFavorite
                self.favorites.removeAll { $0.menuId == menuId }
                if isFavorite {
                    let favorite = FavoriteMenuDTO(
                        menuId: menuId,
                        menuName: menuName,
                        restaurant: restaurant,
                        isDiscontinued: false
                    )
                    self.favorites.insert(favorite, at: 0)
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Sorting

    /// 검색 결과 표시 순서 (기능 명세)
    /// 1. 메뉴명이 검색어로 시작하는 메뉴 먼저
    /// 2. 같은 그룹 안에서는 메뉴명 가나다순
    /// 3. 메뉴명이 같으면(식당만 다른 경우) 서버 순서 유지
    static func sortedForDisplay(_ menus: [MenuSearchDTO], keyword: String) -> [MenuSearchDTO] {
        let keyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        let korean = Locale(identifier: "ko_KR")

        func startsWithKeyword(_ name: String) -> Bool {
            name.range(of: keyword, options: [.caseInsensitive, .anchored]) != nil
        }

        return menus.enumerated().sorted { lhs, rhs in
            let lhsPrefix = startsWithKeyword(lhs.element.menuName)
            let rhsPrefix = startsWithKeyword(rhs.element.menuName)
            if lhsPrefix != rhsPrefix { return lhsPrefix }

            let order = lhs.element.menuName.compare(rhs.element.menuName, locale: korean)
            if order != .orderedSame { return order == .orderedAscending }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }
}
