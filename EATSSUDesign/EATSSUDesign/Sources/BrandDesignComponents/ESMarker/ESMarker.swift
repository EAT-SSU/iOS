//
//  ESMarker.swift
//  EATSSUDesign
//
//  Created by JIWOONG CHOI on 1/31/25.
//

import NMapsMap
import UIKit

/// 네이버 지도(NMapsMap)에서 사용할 커스텀 마커 클래스
/// 말풍선 형태의 UI를 제공하며, 좌우 텍스트를 포함할 수 있음
public final class ESMarker {
    // MARK: - Properties

    /// 네이버 지도(Naver Map)에 표시될 마커 객체
    public private(set) var marker: NMFMarker
    /// 마커와 연결된 데이터 (예: 식당 정보, 위치 정보 등)
    private var data: Any
    /// 말풍선의 왼쪽에 표시될 텍스트
    private var leftText: String
    /// 말풍선의 오른쪽에 표시될 텍스트
    private var rightText: String

    // MARK: - Layout Constants (말풍선 레이아웃 관련 상수)

    private enum Layout {
        /// 말풍선 내부의 좌우 여백 (padding)
        static let horizontalPadding: CGFloat = 12
        /// 말풍선 내부의 상하 여백 (padding)
        static let verticalPadding: CGFloat = 12
        /// 왼쪽과 오른쪽 말풍선 사이의 간격
        static let spacing: CGFloat = 10
        /// 말풍선의 모서리를 둥글게 만드는 반경 (corner radius)
        static let cornerRadius: CGFloat = 15
        /// 왼쪽 말풍선이 시작되는 위치의 좌측 여백
        static let leftBubblePadding: CGFloat = 4
    }

    // MARK: - Initializer (초기화 메서드)

    /// ESMarker 인스턴스를 초기화하는 생성자
    /// - Parameters:
    ///   - position: 마커가 지도에 표시될 위치 (위도, 경도)
    ///   - data: 마커에 연결할 데이터 (예: POI 정보)
    ///   - leftText: 왼쪽 말풍선에 표시할 텍스트
    ///   - rightText: 오른쪽 말풍선에 표시할 텍스트
    public init(position: NMGLatLng, data: Any, leftText: String, rightText: String) {
        marker = NMFMarker()
        marker.position = position
        self.data = data
        self.leftText = leftText
        self.rightText = rightText
        updateImage()
    }

    // MARK: - Methods (기능 구현)

    /// 마커의 위치를 변경하는 함수
    /// - Parameter newPosition: 새롭게 설정할 위치 (위도, 경도)
    public func updatePosition(newPosition: NMGLatLng) {
        marker.position = newPosition
    }

    /// 왼쪽 말풍선의 텍스트를 업데이트하는 함수
    /// - Parameter newLeftText: 변경할 새로운 왼쪽 텍스트
    public func updateLeftText(newLeftText: String) {
        leftText = newLeftText
        updateImage()
    }

    /// 오른쪽 말풍선의 텍스트를 업데이트하는 함수
    /// - Parameter newRightText: 변경할 새로운 오른쪽 텍스트
    public func updateRightText(newRightText: String) {
        rightText = newRightText
        updateImage()
    }

    /// 마커의 이미지를 업데이트하여 현재 텍스트가 반영되도록 설정
    private func updateImage() {
        let image = ESMarker.createESMarkerImage(leftText: leftText, rightText: rightText)
        marker.iconImage = NMFOverlayImage(image: image)
        marker.width = image.size.width
        marker.height = image.size.height
        marker.anchor = CGPoint(x: 0.5, y: 1.0) // 마커의 하단 중심을 지도 좌표에 맞춰 배치
    }

    /// 좌우 텍스트를 포함하는 말풍선 형태의 이미지를 생성
    /// - Parameters:
    ///   - leftText: 왼쪽 말풍선의 텍스트
    ///   - rightText: 오른쪽 말풍선의 텍스트
    /// - Returns: 생성된 UIImage 객체
    private static func createESMarkerImage(leftText: String, rightText: String) -> UIImage {
        let font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 12)

        let leftAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.systemMint,
        ]
        let rightAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black,
        ]

        // 텍스트 크기 계산
        let leftTextSize = (leftText as NSString).size(withAttributes: leftAttributes)
        let rightTextSize = (rightText as NSString).size(withAttributes: rightAttributes)

        // 말풍선 크기 계산
        let leftBubbleWidth = leftTextSize.width + Layout.horizontalPadding * 2
        let leftBubbleHeight = leftTextSize.height + Layout.verticalPadding * 2
        let rightBubbleWidth = rightTextSize.width + Layout.horizontalPadding * 2
        let rightBubbleHeight = rightTextSize.height + Layout.verticalPadding * 2

        let totalWidth = Layout.leftBubblePadding
            + leftBubbleWidth
            + Layout.spacing
            + rightBubbleWidth

        let bubbleHeight = max(leftBubbleHeight, rightBubbleHeight)

        // 배경 높이를 말풍선보다 5 크게 설정
        let totalHeight = bubbleHeight + 5

        // 이미지 렌더러 설정
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: totalWidth, height: totalHeight))
        return renderer.image { _ in
            // 배경 (흰색 사각형)
            let backgroundRect = CGRect(x: 0, y: 0, width: totalWidth, height: totalHeight)
            let backgroundPath = UIBezierPath(
                roundedRect: backgroundRect,
                cornerRadius: Layout.cornerRadius
            )
            UIColor.white.setFill()
            backgroundPath.fill()

            // 말풍선이 배경의 중앙에 오도록 Y축 위치 조정
            let bubbleTop = (totalHeight - bubbleHeight) / 2

            // 왼쪽 말풍선 (연한 민트색 배경)
            let leftBubbleRect = CGRect(
                x: Layout.leftBubblePadding,
                y: bubbleTop,
                width: leftBubbleWidth,
                height: bubbleHeight
            )
            let leftBubblePath = UIBezierPath(roundedRect: leftBubbleRect, cornerRadius: Layout.cornerRadius)
            UIColor.systemMint.withAlphaComponent(0.2).setFill()
            leftBubblePath.fill()

            // 왼쪽 텍스트 그리기
            (leftText as NSString).draw(
                at: CGPoint(
                    x: Layout.leftBubblePadding + Layout.horizontalPadding,
                    y: bubbleTop + (bubbleHeight - leftTextSize.height) / 2
                ),
                withAttributes: leftAttributes
            )

            // 오른쪽 말풍선 (투명한 배경)
            let rightBubbleRect = CGRect(
                x: Layout.leftBubblePadding + leftBubbleWidth + Layout.spacing,
                y: bubbleTop,
                width: rightBubbleWidth,
                height: bubbleHeight
            )
            let rightBubblePath = UIBezierPath(roundedRect: rightBubbleRect, cornerRadius: Layout.cornerRadius)
            UIColor.clear.setFill()
            rightBubblePath.fill()

            // 오른쪽 텍스트 그리기
            (rightText as NSString).draw(
                at: CGPoint(
                    x: Layout.leftBubblePadding + leftBubbleWidth + Layout.spacing + Layout.horizontalPadding,
                    y: bubbleTop + (bubbleHeight - rightTextSize.height) / 2
                ),
                withAttributes: rightAttributes
            )
        }
    }
}
