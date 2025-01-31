//
//  ESMarker.swift
//  EATSSUDesign
//
//  Created by JIWOONG CHOI on 1/31/25.
//

import NMapsMap
import UIKit

/// `ESMarker`는 Naver 지도에 마커를 추가하고, 말풍선 형태의 UI를 렌더링하는 클래스입니다.
/// - `leftText`: 말풍선의 왼쪽 텍스트
/// - `rightText`: 말풍선의 오른쪽 텍스트
public final class ESMarker {
    // MARK: - Properties

    /// Naver 지도에서 사용되는 마커 객체
    public private(set) var marker: NMFMarker
    /// 마커에 포함될 데이터 (유형이 고정되지 않음)
    private var data: Any
    /// 왼쪽 말풍선에 표시될 텍스트
    private var leftText: String
    /// 오른쪽 말풍선에 표시될 텍스트
    private var rightText: String

    /// UI 배치를 위한 레이아웃 상수
    private enum Layout {
        static let horizontalPadding: CGFloat = 12 // 텍스트와 말풍선 가장자리 간격
        static let verticalPadding: CGFloat = 8 // 텍스트와 말풍선 위아래 간격
        static let spacing: CGFloat = 5 // 왼쪽 말풍선과 오른쪽 말풍선 간격
        static let cornerRadius: CGFloat = 15 // 말풍선의 둥근 정도
        static let leftBubblePadding: CGFloat = 4 // 왼쪽 말풍선의 추가 패딩
    }

    // MARK: - 초기화

    /// `ESMarker` 초기화 메서드
    /// - Parameters:
    ///   - position: 마커의 위치 (`NMGLatLng`)
    ///   - data: 마커에 포함할 데이터
    ///   - leftText: 왼쪽 말풍선 텍스트
    ///   - rightText: 오른쪽 말풍선 텍스트
    public init(position: NMGLatLng, data: Any, leftText: String, rightText: String) {
        marker = NMFMarker()
        marker.position = position
        self.data = data
        self.leftText = leftText
        self.rightText = rightText
        updateImage()
    }

    // MARK: - 위치 업데이트

    /// 마커의 위치를 업데이트합니다.
    /// - Parameter newPosition: 새로운 위치 (`NMGLatLng`)
    public func updatePosition(newPosition: NMGLatLng) {
        marker.position = newPosition
    }

    // MARK: - 텍스트 업데이트

    /// 왼쪽 말풍선의 텍스트를 변경합니다.
    /// - Parameter newLeftText: 새로운 왼쪽 텍스트
    public func updateLeftText(newLeftText: String) {
        leftText = newLeftText
        updateImage()
    }

    /// 오른쪽 말풍선의 텍스트를 변경합니다.
    /// - Parameter newRightText: 새로운 오른쪽 텍스트
    public func updateRightText(newRightText: String) {
        rightText = newRightText
        updateImage()
    }

    // MARK: - 이미지 업데이트

    /// 마커의 이미지를 업데이트합니다.
    private func updateImage() {
        let image = ESMarker.createESMarkerImage(leftText: leftText, rightText: rightText)
        marker.iconImage = NMFOverlayImage(image: image)
        marker.width = image.size.width
        marker.height = image.size.height
        marker.anchor = CGPoint(x: 0.5, y: 1.0) // 마커의 기준점을 하단 중앙으로 설정
    }

    // MARK: - UI 렌더링

    /// 말풍선 UI를 생성하는 정적 메서드
    /// - Parameters:
    ///   - leftText: 왼쪽 말풍선 텍스트
    ///   - rightText: 오른쪽 말풍선 텍스트
    /// - Returns: 생성된 `UIImage`
    private static func createESMarkerImage(leftText: String, rightText: String) -> UIImage {
        let font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 12)

        let leftAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: EATSSUDesignAsset.Color.Main.primary.color,
        ]
        let rightAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black,
        ]

        let leftTextSize = (leftText as NSString).size(withAttributes: leftAttributes)
        let rightTextSize = (rightText as NSString).size(withAttributes: rightAttributes)

        let leftBubbleWidth = leftTextSize.width + Layout.horizontalPadding * 2
        let leftBubbleHeight = leftTextSize.height + Layout.verticalPadding * 2
        let rightBubbleWidth = rightTextSize.width + Layout.horizontalPadding * 2
        let rightBubbleHeight = rightTextSize.height + Layout.verticalPadding * 2

        let totalWidth = Layout.leftBubblePadding + leftBubbleWidth + Layout.spacing + rightBubbleWidth
        let bubbleHeight = max(leftBubbleHeight, rightBubbleHeight)
        let totalHeight = bubbleHeight + 5

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: totalWidth, height: totalHeight))
        return renderer.image { context in
            let bubbleTop = (totalHeight - bubbleHeight) / 2

            // 배경 그리기
            drawBackground(in: context, width: totalWidth, height: totalHeight)

            // 왼쪽 말풍선 그리기
            drawLeftBubble(in: context, x: Layout.leftBubblePadding, y: bubbleTop, width: leftBubbleWidth, height: bubbleHeight)

            // 오른쪽 말풍선 그리기
            drawRightBubble(in: context, x: Layout.leftBubblePadding + leftBubbleWidth + Layout.spacing, y: bubbleTop, width: rightBubbleWidth, height: bubbleHeight)

            // 텍스트 그리기
            drawText(in: context, text: leftText, at: CGPoint(x: Layout.leftBubblePadding + Layout.horizontalPadding, y: bubbleTop + (bubbleHeight - leftTextSize.height) / 2), attributes: leftAttributes)
            drawText(in: context, text: rightText, at: CGPoint(x: Layout.leftBubblePadding + leftBubbleWidth + Layout.spacing + Layout.horizontalPadding, y: bubbleTop + (bubbleHeight - rightTextSize.height) / 2), attributes: rightAttributes)
        }
    }

    // MARK: - 컴포넌트 렌더링 메서드

    /// 배경을 렌더링합니다.
    /// - Parameters:
    ///   - context: 그래픽 컨텍스트
    ///   - width: 배경의 너비
    ///   - height: 배경의 높이
    private static func drawBackground(in _: UIGraphicsImageRendererContext, width: CGFloat, height: CGFloat) {
        let backgroundRect = CGRect(x: 0, y: 0, width: width, height: height)
        let backgroundPath = UIBezierPath(roundedRect: backgroundRect, cornerRadius: Layout.cornerRadius)

        // 배경 채우기
        UIColor.white.setFill()
        backgroundPath.fill()

        // 테두리 그리기
        let borderColor = EATSSUDesignAsset.Color.GrayScale.gray300.color
        borderColor.setStroke()
        backgroundPath.lineWidth = 2
        backgroundPath.stroke()
    }

    /// 왼쪽 말풍선을 렌더링합니다.
    /// - Parameters:
    ///   - context: 그래픽 컨텍스트
    ///   - x: 말풍선의 x 위치
    ///   - y: 말풍선의 y 위치
    ///   - width: 말풍선의 너비
    ///   - height: 말풍선의 높이
    private static func drawLeftBubble(in _: UIGraphicsImageRendererContext, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let leftBubbleRect = CGRect(x: x, y: y, width: width, height: height)
        let leftBubblePath = UIBezierPath(roundedRect: leftBubbleRect, cornerRadius: Layout.cornerRadius)

        // 배경 채우기
        UIColor.systemMint.withAlphaComponent(0.2).setFill()
        leftBubblePath.fill()

        // 테두리 그리기
        let borderColor = EATSSUDesignAsset.Color.Main.primary.color
        borderColor.setStroke()
        leftBubblePath.lineWidth = 1
        leftBubblePath.stroke()
    }

    /// 오른쪽 말풍선을 렌더링합니다.
    /// - Parameters:
    ///   - context: 그래픽 컨텍스트
    ///   - x: 말풍선의 x 위치
    ///   - y: 말풍선의 y 위치
    ///   - width: 말풍선의 너비
    ///   - height: 말풍선의 높이
    private static func drawRightBubble(in _: UIGraphicsImageRendererContext, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let rightBubbleRect = CGRect(x: x, y: y, width: width, height: height)
        let rightBubblePath = UIBezierPath(roundedRect: rightBubbleRect, cornerRadius: Layout.cornerRadius)
        UIColor.clear.setFill()
        rightBubblePath.fill()
    }

    /// 텍스트를 렌더링합니다.
    /// - Parameters:
    ///   - context: 그래픽 컨텍스트
    ///   - text: 표시할 텍스트
    ///   - point: 텍스트의 시작 위치
    ///   - attributes: 텍스트의 속성
    private static func drawText(in _: UIGraphicsImageRendererContext, text: String, at point: CGPoint, attributes: [NSAttributedString.Key: Any]) {
        (text as NSString).draw(at: point, withAttributes: attributes)
    }
}
