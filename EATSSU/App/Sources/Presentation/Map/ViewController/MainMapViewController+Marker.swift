//
//  MainMapViewController+Marker.swift
//  EATSSU
//
//  Created by 황상환 on 10/4/25.
//

import UIKit
import NMapsMap
import NMapsGeometry
import EATSSUDesign

// MARK: - Marker Management

extension MainMapViewController {

    /// 마커 데이터를 받아 지도에 클러스터링으로 표시
    func displayMarkers(_ items: [MapMarkerItem]) {
        clusterer?.mapView = nil

        let builder = NMCComplexBuilder<MapMarkerKey>()
        builder.maxScreenDistance = 25
        builder.distanceStrategy = NMCDefaultDistanceStrategy()
        builder.thresholdStrategy = NMCDefaultThresholdStrategy(threshold: 25)

        let leafUpdater = MapLeafMarkerUpdater()
        leafUpdater.items = items
        builder.leafMarkerUpdater = leafUpdater

        let clusterUpdater = MapClusterMarkerUpdater()
        clusterUpdater.viewController = self
        builder.clusterMarkerUpdater = clusterUpdater

        let newClusterer = builder.build()

        var markerData: [AnyHashable: NSObject] = [:]
        for (index, item) in items.enumerated() {
            let key = MapMarkerKey(
                identifier: index,
                position: NMGLatLng(lat: item.latitude, lng: item.longitude)
            )
            markerData[key] = NSNull()
        }
        newClusterer.addAll(markerData)

        clusterer = newClusterer
        clusterer?.mapView = root.mapView.mapView
    }

    // MARK: - Marker Items

    func makeMarkerItem(for partnership: PartnershipDTO) -> MapMarkerItem {
        let isFestival = partnershipFilter == .festival
        return MapMarkerItem(
            title: partnership.storeName,
            latitude: partnership.latitude,
            longitude: partnership.longitude,
            icon: Self.partnershipIcon(for: partnership.restaurantType, isFestival: isFestival),
            onTap: { [weak self] in self?.showPartnershipDetail(for: partnership) }
        )
    }

    func makeMarkerItem(for store: GoodPriceStoreDTO) -> MapMarkerItem {
        MapMarkerItem(
            title: store.storeName,
            latitude: store.latitude,
            longitude: store.longitude,
            icon: Self.goodPriceIcon(for: store.category),
            onTap: { [weak self] in self?.showGoodPriceDetail(for: store) }
        )
    }

    /// 제휴 업종별 아이콘 (축제 여부로 분기)
    static func partnershipIcon(for type: String, isFestival: Bool) -> UIImage {
        if isFestival {
            switch type {
            case "CAFE": return EATSSUDesignAsset.Images.festivalCafePin.image
            case "PUB":  return EATSSUDesignAsset.Images.festivalPubPin.image
            default:     return EATSSUDesignAsset.Images.festivalRestaurantPin.image
            }
        } else {
            switch type {
            case "CAFE": return EATSSUDesignAsset.Images.cafePin.image
            case "PUB":  return EATSSUDesignAsset.Images.pubPin.image
            default:     return EATSSUDesignAsset.Images.restaurantPin.image
            }
        }
    }

    /// 착한가격 업종별 아이콘: 베이커리는 전용, 기타는 카페, 나머지는 수저
    static func goodPriceIcon(for category: String) -> UIImage {
        switch GoodPriceCategory(serverValue: category) {
        case .bakery: return EATSSUDesignAsset.Images.bakeryPin.image
        case .etc:    return EATSSUDesignAsset.Images.cafePin.image
        default:      return EATSSUDesignAsset.Images.restaurantPin.image
        }
    }

    // MARK: - Cluster Image

    /// 클러스터 마커용 원형 이미지 생성 (개수 표시). 줌/팬마다 재호출되므로 (색상, 개수)별로 캐시
    func makeClusterImage(count: Int) -> UIImage {
        let color = clusterColor
        let cacheKey = "\(color.hashValue)-\(count)"
        if let cached = Self.clusterImageCache[cacheKey] {
            return cached
        }

        let size = CGSize(width: 40, height: 40)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            color.setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attributes: [NSAttributedString.Key: Any] = [
                .font: EATSSUDesignFontFamily.Pretendard.bold.font(size: 14),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            let text = NSAttributedString(string: "\(count)", attributes: attributes)
            let textSize = text.size()
            text.draw(in: CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            ))
        }

        Self.clusterImageCache[cacheKey] = image
        return image
    }

    private static var clusterImageCache: [String: UIImage] = [:]
}

// MARK: - Detail Sheets

extension MainMapViewController {

    func setupMarkerTapHandler() {
        root.mapView.mapView.touchDelegate = self
    }

    /// 제휴점 상세 바텀시트 표시
    func showPartnershipDetail(for partnership: PartnershipDTO) {
        MapAnalyticsManager.shared.logClickPartnerRestaurant(
            collegeId: currentCollegeId,
            majorId: currentDepartmentId,
            partnerId: partnership.partnershipInfos.first?.id ?? -1
        )

        let detailVC = PartnershipDetailSheetViewController(partnership: partnership)
        detailVC.loadViewIfNeeded()
        presentSheet(detailVC, heightProvider: { [weak detailVC] in detailVC?.calculatePreferredHeight() })
    }

    /// 착한가격업소 상세 바텀시트 표시
    func showGoodPriceDetail(for store: GoodPriceStoreDTO) {
        MapAnalyticsManager.shared.logClickGoodPriceStore(storeId: store.id)

        let detailVC = GoodPriceDetailSheetViewController(store: store)
        detailVC.loadViewIfNeeded()
        presentSheet(detailVC, heightProvider: { [weak detailVC] in detailVC?.calculatePreferredHeight() })
    }

    /// 커스텀 detent 시트 공통 표시. 표시 후 safe area 확정 시 invalidateDetents()로 높이가 보정됨
    private func presentSheet(_ viewController: UIViewController, heightProvider: @escaping () -> CGFloat?) {
        if let sheet = viewController.sheetPresentationController {
            if #available(iOS 16.0, *) {
                let customDetent = UISheetPresentationController.Detent.custom { _ in heightProvider() }
                sheet.detents = [customDetent, .large()]
            } else {
                sheet.detents = [.medium(), .large()]
            }
            sheet.prefersGrabberVisible = true
        }
        present(viewController, animated: true)
    }
}

// MARK: - NMFMapViewTouchDelegate

extension MainMapViewController: NMFMapViewTouchDelegate {

    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
    }

    func mapView(_ mapView: NMFMapView, didTap symbol: NMFSymbol) -> Bool {
        return false
    }
}
