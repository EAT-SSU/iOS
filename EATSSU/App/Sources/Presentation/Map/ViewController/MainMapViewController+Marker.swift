//
//  MainMapViewController+Marker.swift
//  EATSSU
//
//  Created by 황상환 on 10/4/25.
//

// MainMapViewController+Marker.swift

import UIKit
import NMapsMap
import NMapsGeometry
import EATSSUDesign

// MARK: - Marker Management
extension MainMapViewController {
    
    final class ClusterMarkerUpdater: NMCDefaultClusterMarkerUpdater {
        // MainMapViewController의 makeClusterImage 함수를 사용하기 위한 참조
        weak var vc: MainMapViewController?

        override func updateClusterMarker(_ info: NMCClusterMarkerInfo, _ marker: NMFMarker) {
            super.updateClusterMarker(info, marker)
            
            // vc의 makeClusterImage 함수를 호출해 원형 이미지를 가져옵니다.
            guard let image = vc?.makeClusterImage(count: info.size) else { return }
            
            // 마커의 아이콘을 우리가 만든 원형 이미지로 설정합니다.
            marker.iconImage = NMFOverlayImage(image: image)
            marker.width = 40
            marker.height = 40
        }
    }

    
    func displayMarkers(_ partnerships: [PartnershipDTO]) {
        // 1. 기존 클러스터러가 있다면 지도에서 제거
        clusterer?.mapView = nil

        // 2. NMCBuilder를 ItemKey 타입으로 생성
        let builder = NMCBuilder<ItemKey>()
        
        // 3. LeafMarkerUpdater 인스턴스 생성 및 데이터 전달
        let leafMarkerUpdater = LeafMarkerUpdater()
        leafMarkerUpdater.partnerships = partnerships
        
        // =========================================================
        // ✅ 2. ClusterMarkerUpdater를 생성하고 할당합니다.
        let clusterMarkerUpdater = ClusterMarkerUpdater()
        clusterMarkerUpdater.vc = self // 참조 연결
        builder.clusterMarkerUpdater = clusterMarkerUpdater
        // =========================================================
        
        // 5. 빌더에 leafMarkerUpdater 할당 (build() 전에 해야 함)
        builder.leafMarkerUpdater = leafMarkerUpdater
        
        // 6. 빌더로 클러스터러 생성
        self.clusterer = builder.build()
        
        // 7. 제휴점 데이터를 [ItemKey: Any] 형태의 딕셔너리로 변환
        var keyTagMap: [AnyHashable: Any] = [:]
        for (index, partnership) in partnerships.enumerated() {
            let key = ItemKey(identifier: index,
                              position: NMGLatLng(lat: partnership.latitude, lng: partnership.longitude))
            keyTagMap[key] = NSNull()
        }
        
        // 8. 클러스터러에 모든 데이터 추가
        clusterer?.addAll(keyTagMap as! [AnyHashable : NSObject])
        
        // 9. 클러스터러를 지도에 표시
        clusterer?.mapView = root.mapView.mapView
    }
    
    // 클러스터 마커의 디자인을 정의하는 함수 (원 + 숫자)
    private func makeClusterImage(count: Int) -> UIImage {
        // ... (이 함수의 내용은 이전과 동일하게 유지) ...
        let size = CGSize(width: 40, height: 40)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let circleRect = CGRect(origin: .zero, size: size)
            EATSSUDesignAsset.Color.Main.primary.color.setFill()
            context.cgContext.fillEllipse(in: circleRect)
            
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
            let textRect = CGRect(x: (size.width - textSize.width) / 2,
                                  y: (size.height - textSize.height) / 2,
                                  width: textSize.width,
                                  height: textSize.height)
            attributedString.draw(in: textRect)
        }
    }
}
