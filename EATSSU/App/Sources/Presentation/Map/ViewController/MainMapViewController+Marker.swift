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
    
    // MARK: - Display Markers
    
    /// 제휴점 데이터를 받아 지도에 마커 클러스터링으로 표시
    func displayMarkers(_ partnerships: [PartnershipDTO]) {
        removeExistingClusterer()
        
        let newClusterer = buildClusterer(with: partnerships)
        
        let markerData = createMarkerData(from: partnerships)
        newClusterer.addAll(markerData as! [AnyHashable: NSObject])
        
        attachClustererToMap(newClusterer)
    }
    
    // MARK: - Private Methods
    
    /// 기존 클러스터러 제거
    private func removeExistingClusterer() {
        clusterer?.mapView = nil
    }
    
    /// 새로운 클러스터러 생성 및 설정
    private func buildClusterer(with partnerships: [PartnershipDTO]) -> NMCClusterer<PartnershipMarkerKey> {
        let builder = NMCBuilder<PartnershipMarkerKey>()
        
        builder.leafMarkerUpdater = createLeafMarkerUpdater(with: partnerships)
        builder.clusterMarkerUpdater = createClusterMarkerUpdater()
        
        return builder.build()
    }
    
    /// Leaf 마커 업데이터 생성
    private func createLeafMarkerUpdater(with partnerships: [PartnershipDTO]) -> PartnershipLeafMarkerUpdater {
        let leafMarkerUpdater = PartnershipLeafMarkerUpdater()
        leafMarkerUpdater.partnerships = partnerships
        
        leafMarkerUpdater.onMarkerTap = { [weak self] partnership in
            self?.showPartnershipDetail(for: partnership)
        }
        
        return leafMarkerUpdater
    }
    
    /// 클러스터 마커 업데이터 생성
    private func createClusterMarkerUpdater() -> PartnershipClusterMarkerUpdater {
        let clusterMarkerUpdater = PartnershipClusterMarkerUpdater()
        clusterMarkerUpdater.viewController = self
        return clusterMarkerUpdater
    }
    
    /// 제휴점 데이터를 마커 키-값 딕셔너리로 변환
    private func createMarkerData(from partnerships: [PartnershipDTO]) -> [AnyHashable: Any] {
        var markerData: [AnyHashable: Any] = [:]
        
        for (index, partnership) in partnerships.enumerated() {
            let key = PartnershipMarkerKey(
                identifier: index,
                position: NMGLatLng(lat: partnership.latitude, lng: partnership.longitude)
            )
            markerData[key] = NSNull()
        }
        
        return markerData
    }
    
    /// 클러스터러를 지도에 연결
    private func attachClustererToMap(_ newClusterer: NMCClusterer<PartnershipMarkerKey>) {
        self.clusterer = newClusterer
        clusterer?.mapView = root.mapView.mapView
    }
    
    // MARK: - Cluster Image
    
    /// 클러스터 마커용 원형 이미지 생성 (개수 표시)
    func makeClusterImage(count: Int) -> UIImage {
        let size = CGSize(width: 40, height: 40)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            drawCircle(in: context, size: size)
            drawCountText(in: context, count: count, size: size)
        }
    }
    
    // MARK: - Private Helpers
    
    /// 원형 배경 그리기
    private func drawCircle(in context: UIGraphicsImageRendererContext, size: CGSize) {
        let circleRect = CGRect(origin: .zero, size: size)
        EATSSUDesignAsset.Color.Main.primary.color.setFill()
        context.cgContext.fillEllipse(in: circleRect)
    }
    
    /// 중앙에 개수 텍스트 그리기
    private func drawCountText(in context: UIGraphicsImageRendererContext, count: Int, size: CGSize) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: EATSSUDesignFontFamily.Pretendard.bold.font(size: 14),
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle
        ]
        
        let text = "\(count)"
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedString.size()
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        attributedString.draw(in: textRect)
    }
}

// MARK: - Marker Tap Handler

extension MainMapViewController {
    
    /// 마커 탭 델리게이트 설정
    func setupMarkerTapHandler() {
        root.mapView.mapView.touchDelegate = self
    }
    
    /// 제휴점 상세 바텀시트 표시
    func showPartnershipDetail(for partnership: PartnershipDTO) {
        let detailVC = PartnershipDetailSheetViewController(
            storeName: partnership.storeName,
            restaurantType: partnership.restaurantType,
            partnershipInfos: partnership.partnershipInfos
        )
        
        // 뷰가 로드된 후 높이 계산
        detailVC.loadViewIfNeeded()
        
        if let sheet = detailVC.sheetPresentationController {
            let contentHeight = detailVC.calculatePreferredHeight()
            
            // iOS 16.0 이상에서만 custom detent 사용
            if #available(iOS 16.0, *) {
                let customDetent = UISheetPresentationController.Detent.custom { _ in
                    return contentHeight
                }
                sheet.detents = [customDetent]
            } else {
                // iOS 16.0 미만에서는 medium detent 사용
                sheet.detents = [.medium()]
            }
            
            sheet.prefersGrabberVisible = true
        }
        
        present(detailVC, animated: true)
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
