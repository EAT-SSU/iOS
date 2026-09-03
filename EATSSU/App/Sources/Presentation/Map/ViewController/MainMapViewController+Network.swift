//
//  MainMapViewController+Network.swift
//  EATSSU
//
//  Created by 황상환 on 10/4/25.
//

import Foundation

// MARK: - Partnership Requests

extension MainMapViewController {

    /// 전체 제휴 데이터를 받아 캐시에 저장하고 축제 제휴 마커를 표시
    /// 캐시가 있으면 재요청 없이 사용한다 (탭바 재탭 시 reloadContent가 캐시를 비움)
    func refreshAllPartnerships() {
        if !cachedAllPartnerships.isEmpty {
            _ = beginLoad()
            applyPartnershipMarkers(from: cachedAllPartnerships, periodType: .festival)
            return
        }

        let generation = beginLoad()
        NetworkService.shared.request(
            PartnershipRouter.getAllPartnerships,
            responseType: [PartnershipDTO].self,
            useAuth: true
        ) { [weak self] result in
            guard let self, self.isCurrentLoad(generation) else { return }
            switch result {
            case .success(let partnerships):
                self.cachedAllPartnerships = partnerships
                self.applyPartnershipMarkers(from: partnerships, periodType: .festival)

            case .failure(let error):
                print("제휴 조회 실패: \(error.localizedDescription)")
                self.cachedAllPartnerships = []
                #if !DEBUG
                self.displayMarkers([])
                self.showStoreLoadFailedToast()
                #endif
            }

            #if DEBUG
            // 서버에 제휴 데이터가 없거나 실패한 동안 Mock으로 대체 (DEBUG 빌드 전용, 실패 토스트는 띄우지 않음)
            if self.cachedAllPartnerships.isEmpty {
                self.cachedAllPartnerships = PartnershipMockData.samples
                self.applyPartnershipMarkers(from: self.cachedAllPartnerships, periodType: .festival)
            }
            #endif
        }
    }

    /// 내 학과 제휴를 받아 현재 업종 필터에 맞춰 마커 표시. 캐시가 있으면 재요청 없이 필터만 적용
    func fetchMyPartnerships() {
        guard hasDepartment else {
            displayMarkers([])
            return
        }

        if !cachedMyPartnerships.isEmpty {
            _ = beginLoad()
            applyPartnershipMarkers(from: cachedMyPartnerships, periodType: .normal)
            return
        }

        let generation = beginLoad()
        NetworkService.shared.request(
            MyRouter.getMyPartnerships,
            responseType: [PartnershipDTO].self,
            useAuth: true
        ) { [weak self] result in
            guard let self, self.isCurrentLoad(generation) else { return }
            switch result {
            case .success(let partnerships):
                self.cachedMyPartnerships = partnerships
                self.hasFetchedMyPartnerships = true
                self.applyPartnershipMarkers(from: partnerships, periodType: .normal)
                self.presentPendingDetailIfNeeded()

            case .failure(let error):
                print("내 제휴 조회 실패: \(error.localizedDescription)")
                self.displayMarkers([])
                self.showStoreLoadFailedToast()
            }
        }
    }

    /// periodType + 현재 업종 필터로 걸러서 마커 표시
    private func applyPartnershipMarkers(from partnerships: [PartnershipDTO], periodType: PartnershipPeriodType) {
        var filtered = Self.filterPartnerships(partnerships, by: periodType)
        if let type = partnershipFilter.restaurantType {
            filtered = filtered.filter { $0.restaurantType == type }
        }
        // 시트는 필터된 항목만 보여주되, 찜은 업체의 전체 항목을 대상으로 해야 하므로 원본을 함께 넘긴다
        let fullByKey = Dictionary(partnerships.map { ($0.storeKey, $0) }, uniquingKeysWith: { first, _ in first })
        displayMarkers(filtered.map { makeMarkerItem(for: $0, likeTarget: fullByKey[$0.storeKey]) })
    }

    private static func filterPartnerships(
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
