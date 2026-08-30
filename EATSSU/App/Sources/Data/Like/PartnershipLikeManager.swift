//
//  PartnershipLikeManager.swift
//  EATSSU
//
//  Created by 황상환 on 8/30/26.
//

import Foundation

/// 제휴 찜 상태의 앱 내 단일 소스
///
/// - 서버 API는 제휴 **항목** 단위(`POST /partnerships/{id}/like`, 토글)지만 화면의 하트는 **업체** 단위이므로
///   업체의 모든 제휴 항목을 함께 켜고 끈다. 상태가 다른 항목만 호출해 토글 API와 어긋나지 않게 한다.
/// - 찜한 순서는 서버 응답에 없어 로컬(UserDefaults)에 기록하고 "최근 추가순" 정렬에 사용한다.
/// - 지도 시트와 찜 목록이 같은 인스턴스를 보므로 어느 화면에서 바꿔도 즉시 일치한다.
final class PartnershipLikeManager {

    // MARK: - Singleton

    static let shared = PartnershipLikeManager()

    private init() {
        likedAtByStoreKey = (UserDefaults.standard.dictionary(forKey: Constant.likedOrderKey) as? [String: Double]) ?? [:]
    }

    private enum Constant {
        static let likedOrderKey = "partnershipLikedOrder"
    }

    // MARK: - State

    /// 찜한 제휴 항목 id. 업체 찜 여부는 소속 항목이 모두 포함됐는지로 판정
    private(set) var likedPartnershipIds: Set<Int> = []

    /// 마지막으로 받아온 찜 업체 목록 (최근 추가순)
    private(set) var likedStores: [PartnershipDTO] = []

    /// 찜 목록을 한 번이라도 서버에서 받아왔는지
    private(set) var hasLoaded = false

    /// 업체별 찜한 시각 (최근 추가순 정렬용, 로컬 보관)
    private var likedAtByStoreKey: [String: Double]

    /// 이 세션에서 토글에 성공한 항목의 최신 상태. 찜 목록 조회가 실패했거나 아직 안 됐을 때도 하트가 서버와 일치하게 한다
    private var toggledStates: [Int: Bool] = [:]

    /// 토글이 반영될 때마다 증가. 토글 이전에 시작된 목록 조회 응답이 최신 로컬 상태를 덮어쓰지 않게 한다
    private var stateVersion = 0

    /// 로그아웃·탈퇴·세션 만료 시 호출. 다른 계정의 찜 상태가 남지 않도록 메모리와 로컬 순서 기록을 모두 비운다
    func reset() {
        likedPartnershipIds = []
        likedStores = []
        hasLoaded = false
        likedAtByStoreKey = [:]
        toggledStates = [:]
        stateVersion += 1
        UserDefaults.standard.removeObject(forKey: Constant.likedOrderKey)
    }

    // MARK: - Query

    func isLiked(_ store: PartnershipDTO) -> Bool {
        !store.partnershipInfos.isEmpty && store.partnershipInfos.allSatisfy(currentlyLiked)
    }

    /// 찜 상태를 한 번은 서버에서 받아온 뒤 이어서 실행. 이미 받아왔으면 즉시 실행
    func ensureLoaded(completion: @escaping () -> Void) {
        guard !hasLoaded else {
            completion()
            return
        }
        refresh { _ in completion() }
    }

    // MARK: - Fetch

    /// 찜 목록을 서버에서 받아 상태를 갱신하고 최근 추가순으로 정렬해 돌려준다
    func refresh(completion: @escaping (Result<[PartnershipDTO], Error>) -> Void) {
        let version = stateVersion
        NetworkService.shared.request(
            MyRouter.getLikedPartnerships,
            responseType: [PartnershipDTO].self,
            useAuth: true
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let stores):
                // 조회 중에 토글이 있었으면 이 응답은 이미 낡은 것이므로 로컬 상태를 유지한다
                guard version == self.stateVersion else {
                    completion(.success(self.likedStores))
                    return
                }
                self.toggledStates = [:]
                self.likedPartnershipIds = Set(stores.flatMap(Self.likedIds(in:)))
                self.likedStores = self.sortedByRecent(stores)
                self.hasLoaded = true
                self.pruneOrder(keeping: stores)
                completion(.success(self.likedStores))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Update

    /// 업체 단위 찜 설정. 완료 시 로컬 상태(항목 id, 목록, 순서)까지 반영한다
    func setLiked(_ liked: Bool, store: PartnershipDTO, completion: @escaping (Result<Void, Error>) -> Void) {
        // 찜 목록을 받기 전에 토글하면 빈 집합 기준으로 잘못 판단하므로 먼저 확보한다
        ensureLoaded { [weak self] in
            guard let self else { return }
            self.toggle(liked: liked, store: store, completion: completion)
        }
    }

    /// 항목별 현재 찜 상태와 다른 것만 서버 토글. 목록 확보에 실패한 경우엔 지도 응답의 isLiked를 기준으로 삼는다
    private func toggle(liked: Bool, store: PartnershipDTO, completion: @escaping (Result<Void, Error>) -> Void) {
        let targets = store.partnershipInfos
            .filter { currentlyLiked($0) != liked }
            .map(\.id)
        guard !targets.isEmpty else {
            applyLocalState(liked: liked, store: store)
            completion(.success(()))
            return
        }

        let group = DispatchGroup()
        var toggledIds: [Int] = []
        var firstError: Error?

        for id in targets {
            group.enter()
            NetworkService.shared.request(
                PartnershipRouter.toggleLike(partnershipId: id),
                responseType: Bool.self,
                useAuth: true
            ) { result in
                switch result {
                case .success:
                    toggledIds.append(id)
                case .failure(let error):
                    if firstError == nil { firstError = error }
                }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            // 성공한 항목만 로컬에 반영해 서버 상태와 어긋나지 않게 한다
            for id in toggledIds {
                self.toggledStates[id] = liked
                if liked { self.likedPartnershipIds.insert(id) } else { self.likedPartnershipIds.remove(id) }
            }
            self.stateVersion += 1
            if let firstError {
                // 일부만 성공한 경우에도 목록/순서를 항목 상태와 일치시킨다 (전부 찜일 때만 목록에 남김)
                self.applyLocalState(liked: self.isLiked(store), store: store)
                completion(.failure(firstError))
                return
            }
            self.applyLocalState(liked: liked, store: store)
            completion(.success(()))
        }
    }

    /// 여러 업체를 한 번에 찜 해제 (편집 모드 삭제). 하나라도 실패하면 failure
    func removeLikes(stores: [PartnershipDTO], completion: @escaping (Result<Void, Error>) -> Void) {
        let group = DispatchGroup()
        var firstError: Error?
        for store in stores {
            group.enter()
            setLiked(false, store: store) { result in
                if case .failure(let error) = result, firstError == nil { firstError = error }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            if let firstError { completion(.failure(firstError)) } else { completion(.success(())) }
        }
    }

    // MARK: - Private

    /// 항목 찜 상태: 이 세션의 토글 결과 > 서버 찜 목록 > (목록 미확보 시) 지도 응답의 isLiked
    private func currentlyLiked(_ info: PartnershipInfoDTO) -> Bool {
        if let toggled = toggledStates[info.id] { return toggled }
        return hasLoaded ? likedPartnershipIds.contains(info.id) : info.isLiked
    }

    /// 찜 목록 응답에서 실제 찜된 항목 id. 플래그가 하나도 없으면(구버전 응답) 소속 항목 전부로 간주
    private static func likedIds(in store: PartnershipDTO) -> [Int] {
        let flagged = store.partnershipInfos.filter(\.isLiked).map(\.id)
        return flagged.isEmpty ? store.partnershipIds : flagged
    }

    private func applyLocalState(liked: Bool, store: PartnershipDTO) {
        if liked {
            likedAtByStoreKey[store.storeKey] = Date().timeIntervalSince1970
            likedStores.removeAll { $0.storeKey == store.storeKey }
            likedStores.insert(store, at: 0)
        } else {
            likedAtByStoreKey.removeValue(forKey: store.storeKey)
            likedStores.removeAll { $0.storeKey == store.storeKey }
        }
        persistOrder()
    }

    /// 로컬에 기록된 찜 시각 기준 최근순. 기록이 없는 항목(다른 기기에서 찜 등)은 서버 순서대로 뒤에 둔다
    private func sortedByRecent(_ stores: [PartnershipDTO]) -> [PartnershipDTO] {
        let indexed = stores.enumerated().map { ($0.offset, $0.element) }
        return indexed.sorted { lhs, rhs in
            let lhsTime = likedAtByStoreKey[lhs.1.storeKey]
            let rhsTime = likedAtByStoreKey[rhs.1.storeKey]
            switch (lhsTime, rhsTime) {
            case let (l?, r?): return l > r
            case (_?, nil): return true
            case (nil, _?): return false
            case (nil, nil): return lhs.0 < rhs.0
            }
        }.map { $0.1 }
    }

    private func pruneOrder(keeping stores: [PartnershipDTO]) {
        let keys = Set(stores.map(\.storeKey))
        likedAtByStoreKey = likedAtByStoreKey.filter { keys.contains($0.key) }
        persistOrder()
    }

    private func persistOrder() {
        UserDefaults.standard.set(likedAtByStoreKey, forKey: Constant.likedOrderKey)
    }
}
