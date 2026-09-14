//
//  MainMapViewController+Network.swift
//  EATSSU
//
//  Created by 황상환 on 10/4/25.
//

import Foundation

// MARK: - Partnership Requests

extension MainMapViewController {

    /// 내 학과 제휴와 (축제 기간이면) 축제 제휴를 함께 받아 한 지도에 표시한다
    /// 두 응답을 업체 단위로 합치고, 업종 필터는 합친 결과에 적용한다
    func fetchPartnerships() {
        guard hasDepartment else {
            displayMarkers([])
            return
        }

        // 성공적으로 받아온 적이 없을 때만 요청한다 (빈 응답도 성공으로 보고 반복 요청하지 않는다)
        let needsMy = !hasLoadedMyPartnerships
        let needsFestival = isFestivalPartnershipEnabled && !hasLoadedFestivalPartnerships
        let generation = beginLoad()

        // 이미 받아둔 데이터로 먼저 그린다 (업종 필터 전환이 네트워크 응답을 기다리지 않도록)
        applyPartnershipMarkers()

        guard needsMy || needsFestival else { return }

        let group = DispatchGroup()
        var myFailed = false

        if needsMy {
            group.enter()
            NetworkService.shared.request(
                MyRouter.getMyPartnerships,
                responseType: [PartnershipDTO].self,
                useAuth: true
            ) { [weak self] result in
                defer { group.leave() }
                guard let self, self.isCurrentLoad(generation) else { return }
                switch result {
                case .success(let partnerships):
                    self.cachedMyPartnerships = partnerships
                    self.hasLoadedMyPartnerships = true
                    self.hasAttemptedMyPartnershipsFetch = true
                case .failure(let error):
                    // 실패는 "시도함"으로 남기지 않는다. 찜 상세 진입 시 다시 조회해 전체 단과대 원본이 노출되지 않게 한다
                    print("내 제휴 조회 실패: \(error.localizedDescription)")
                    myFailed = true
                }
            }
        }

        if needsFestival {
            group.enter()
            NetworkService.shared.request(
                PartnershipRouter.getAllPartnerships,
                responseType: [PartnershipDTO].self,
                useAuth: true
            ) { [weak self] result in
                defer { group.leave() }
                guard let self, self.isCurrentLoad(generation) else { return }
                switch result {
                case .success(let partnerships):
                    self.cachedFestivalPartnerships = Self.filterPartnerships(partnerships, by: .festival)
                    self.hasLoadedFestivalPartnerships = true
                case .failure(let error):
                    // 축제 제휴는 부가 정보이므로 실패해도 기존 제휴만으로 지도를 그린다
                    print("축제 제휴 조회 실패: \(error.localizedDescription)")
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self, self.isCurrentLoad(generation) else { return }

            #if DEBUG
            // 서버에 축제 데이터가 없는 동안 Mock으로 확인 (개발 빌드 전용)
            if self.isFestivalPartnershipEnabled, self.cachedFestivalPartnerships.isEmpty {
                self.cachedFestivalPartnerships = Self.filterPartnerships(PartnershipMockData.samples, by: .festival)
            }
            #endif

            // 한쪽이 실패해도 받아온 쪽은 그대로 그린다 (축제만 성공한 경우 지도가 비지 않도록)
            self.applyPartnershipMarkers()
            if myFailed, self.cachedMyPartnerships.isEmpty {
                self.showStoreLoadFailedToast()
            }
            self.presentPendingDetailIfNeeded()
        }
    }

    /// 현재 업종 필터에 맞춰 합쳐진 제휴 마커를 표시
    func applyPartnershipMarkers() {
        var merged = Self.mergedPartnerships(
            my: cachedMyPartnerships,
            festival: isFestivalPartnershipEnabled ? cachedFestivalPartnerships : []
        )
        if let type = partnershipFilter.restaurantType {
            merged = merged.filter { $0.restaurantType == type }
        }
        displayMarkers(merged.map { makeMarkerItem(for: $0) })
    }

    /// 내 학과 제휴 + 축제 제휴를 업체(storeKey) 단위로 합친다
    /// 같은 업체가 양쪽에 있으면 제휴 항목을 합치고, 순서는 내 학과 제휴 → 축제 전용 업체 순으로 둔다
    static func mergedPartnerships(
        my: [PartnershipDTO],
        festival: [PartnershipDTO]
    ) -> [PartnershipDTO] {
        var order: [String] = []
        var byKey: [String: PartnershipDTO] = [:]

        for store in my + festival {
            guard let existing = byKey[store.storeKey] else {
                order.append(store.storeKey)
                byKey[store.storeKey] = store
                continue
            }
            let knownIds = Set(existing.partnershipInfos.map(\.id))
            byKey[store.storeKey] = PartnershipDTO(
                storeName: existing.storeName,
                longitude: existing.longitude,
                latitude: existing.latitude,
                restaurantType: existing.restaurantType,
                naverMapUrl: existing.naverMapUrl ?? store.naverMapUrl,
                kakaoMapUrl: existing.kakaoMapUrl ?? store.kakaoMapUrl,
                partnershipInfos: existing.partnershipInfos
                    + store.partnershipInfos.filter { !knownIds.contains($0.id) }
            )
        }
        return order.compactMap { byKey[$0] }
    }

    /// 축제 제휴 항목이 하나라도 있으면 축제 마커로 표시한다 (기존 제휴와 겹치는 업체는 축제 우선)
    static func isFestivalStore(_ store: PartnershipDTO) -> Bool {
        store.partnershipInfos.contains { $0.periodType == .festival }
    }

    /// 찜 대상 업체. 축제 제휴는 찜할 수 없으므로 일반 제휴 항목만 남기고, 없으면 nil(하트 숨김)
    static func likeTarget(for store: PartnershipDTO) -> PartnershipDTO? {
        let normalInfos = store.partnershipInfos.filter { $0.periodType == .normal }
        guard !normalInfos.isEmpty else { return nil }
        return PartnershipDTO(
            storeName: store.storeName,
            longitude: store.longitude,
            latitude: store.latitude,
            restaurantType: store.restaurantType,
            naverMapUrl: store.naverMapUrl,
            kakaoMapUrl: store.kakaoMapUrl,
            partnershipInfos: normalInfos
        )
    }

    static func filterPartnerships(
        _ partnerships: [PartnershipDTO],
        by periodType: PartnershipPeriodType
    ) -> [PartnershipDTO] {
        partnerships.compactMap { partnership in
            let matchingInfos = partnership.partnershipInfos.filter { $0.periodType == periodType }
            guard !matchingInfos.isEmpty else { return nil }
            return PartnershipDTO(
                storeName: partnership.storeName,
                longitude: partnership.longitude,
                latitude: partnership.latitude,
                restaurantType: partnership.restaurantType,
                naverMapUrl: partnership.naverMapUrl,
                kakaoMapUrl: partnership.kakaoMapUrl,
                partnershipInfos: matchingInfos
            )
        }
    }

    func fetchDepartment(completion: (() -> Void)? = nil) {
        NetworkService.shared.request(
            MyRouter.getDepartment,
            responseType: GetDepartmentResponse.self,
            useAuth: true
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let department):
                if self.currentDepartmentId != department.departmentId {
                    // 학과가 바뀌면 내 제휴 캐시는 더 이상 유효하지 않다
                    self.cachedMyPartnerships = []
                    self.hasLoadedMyPartnerships = false
                    self.hasAttemptedMyPartnershipsFetch = false
                }
                self.currentDepartmentName = department.departmentName
                self.currentDepartmentId = department.departmentId
                self.currentCollegeId = department.collegeId

                // Realm 데이터도 함께 동기화하여 서버-클라이언트 불일치 방지
                if let userInfo = UserInfoManager.shared.getCurrentUserInfo() {
                    UserInfoManager.shared.updateDepartment(
                        for: userInfo,
                        collegeId: department.collegeId,
                        collegeName: department.collegeName,
                        departmentId: department.departmentId,
                        departmentName: department.departmentName
                    )
                }

            case .failure(let error):
                // 일시적 조회 실패를 '학과 없음'으로 오판하지 않도록 기존 값(없으면 Realm 저장값)을 유지한다
                print("학과 조회 실패: \(error.localizedDescription)")
                self.seedDepartmentFromRealmIfNeeded()
            }

            completion?()
        }
    }
}

// MARK: - Good Price Store Requests

extension MainMapViewController {

    /// 착한가격업소 마커 로드. 캐시가 있으면 카테고리만 필터, 없으면 전체 목록을 받아온다
    func loadGoodPriceMarkers() {
        if !cachedGoodPriceStores.isEmpty {
            _ = beginLoad()
            applyGoodPriceMarkers()
            return
        }

        let generation = beginLoad()
        NetworkService.shared.request(
            GoodPriceStoreRouter.getStores,
            responseType: [GoodPriceStoreDTO].self,
            useAuth: false
        ) { [weak self] result in
            guard let self, self.isCurrentLoad(generation) else { return }
            switch result {
            case .success(let stores):
                self.cachedGoodPriceStores = stores
                self.applyGoodPriceMarkers()

            case .failure(let error):
                print("착한가격업소 조회 실패: \(error.localizedDescription)")
                self.cachedGoodPriceStores = []
                self.displayMarkers([])
                self.showStoreLoadFailedToast()
            }
        }
    }

    private func applyGoodPriceMarkers() {
        let filtered: [GoodPriceStoreDTO]
        if let serverValue = goodPriceCategory.serverValue {
            filtered = cachedGoodPriceStores.filter { $0.category == serverValue }
        } else {
            filtered = cachedGoodPriceStores
        }
        displayMarkers(filtered.map { makeMarkerItem(for: $0) })
    }
}
