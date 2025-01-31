//
//  ESMarker.swift
//  EATSSUDesign
//
//  Created by JIWOONG CHOI on 1/31/25.
//

import NMapsMap
import UIKit

public final class ESMarker {
    // MARK: - Properties

    public private(set) var marker: NMFMarker
    private var data: Any
    private var leftText: String
    private var rightText: String

    // MARK: - Layout Constants

    private enum Layout {
        static let horizontalPadding: CGFloat = 12
        static let verticalPadding: CGFloat = 12
        static let spacing: CGFloat = 10
        static let cornerRadius: CGFloat = 15
        static let tailHeight: CGFloat = 8
        static let leftBubblePadding: CGFloat = 20
    }

    // MARK: - Initializer

    public init(position: NMGLatLng, data: Any, leftText: String, rightText: String) {
        marker = NMFMarker()
        marker.position = position
        self.data = data
        self.leftText = leftText
        self.rightText = rightText
        updateImage()
    }

    // MARK: - Methods

    public func updatePosition(newPosition: NMGLatLng) {
        marker.position = newPosition
    }

    public func updateLeftText(newLeftText: String) {
        leftText = newLeftText
        updateImage()
    }

    public func updateRightText(newRightText: String) {
        rightText = newRightText
        updateImage()
    }

    private func updateImage() {
        let image = ESMarker.createESMarkerImage(leftText: leftText, rightText: rightText)
        marker.iconImage = NMFOverlayImage(image: image)
        marker.width = image.size.width
        marker.height = image.size.height
        marker.anchor = CGPoint(x: 0.5, y: 1.0) // 🔼 꼬리가 마커 위치에 정확히 오도록 앵커 조정
    }

    private static func createESMarkerImage(leftText: String, rightText: String) -> UIImage {
        // Font
        let font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 12)

        // Text Attributes
        let leftAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.systemMint,
        ]
        let rightAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black,
        ]

        // Text Size Calculation
        let leftTextSize = (leftText as NSString).size(withAttributes: leftAttributes)
        let rightTextSize = (rightText as NSString).size(withAttributes: rightAttributes)

        // Bubble Dimensions
        let leftBubbleWidth = leftTextSize.width + Layout.horizontalPadding * 2
        let leftBubbleHeight = leftTextSize.height + Layout.verticalPadding * 2
        let rightBubbleWidth = rightTextSize.width + Layout.horizontalPadding * 2

        let totalWidth = Layout.leftBubblePadding + leftBubbleWidth + Layout.spacing + rightBubbleWidth
        let bubbleHeight = max(leftBubbleHeight, rightTextSize.height + Layout.verticalPadding * 2)
        let totalHeight = bubbleHeight + Layout.tailHeight

        // Image Rendering
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: totalWidth, height: totalHeight))
        return renderer.image { _ in
            // 1. Background & Tail
            let backgroundRect = CGRect(x: 0, y: 0, width: totalWidth, height: bubbleHeight)
            let backgroundPath = UIBezierPath(roundedRect: backgroundRect, cornerRadius: Layout.cornerRadius)
            UIColor.white.setFill()
            backgroundPath.fill()

            // Tail Drawing (Centered)
            let tailPath = UIBezierPath()
            let tailCenterX = totalWidth / 2
            tailPath.move(to: CGPoint(x: tailCenterX - 6, y: bubbleHeight))
            tailPath.addLine(to: CGPoint(x: tailCenterX, y: totalHeight))
            tailPath.addLine(to: CGPoint(x: tailCenterX + 6, y: bubbleHeight))
            tailPath.close()
            UIColor.white.setFill()
            tailPath.fill()

            // 2. Left Bubble
            let leftBubbleRect = CGRect(
                x: Layout.leftBubblePadding,
                y: 0,
                width: leftBubbleWidth,
                height: bubbleHeight
            )
            let leftBubblePath = UIBezierPath(roundedRect: leftBubbleRect, cornerRadius: Layout.cornerRadius)
            UIColor.systemMint.withAlphaComponent(0.2).setFill()
            leftBubblePath.fill()

            // Left Text Position
            (leftText as NSString).draw(
                at: CGPoint(
                    x: Layout.leftBubblePadding + Layout.horizontalPadding,
                    y: (bubbleHeight - leftTextSize.height) / 2
                ),
                withAttributes: leftAttributes
            )

            // 3. Right Bubble
            let rightBubbleRect = CGRect(
                x: Layout.leftBubblePadding + leftBubbleWidth + Layout.spacing,
                y: 0,
                width: rightBubbleWidth,
                height: bubbleHeight
            )
            let rightBubblePath = UIBezierPath(roundedRect: rightBubbleRect, cornerRadius: Layout.cornerRadius)
            UIColor.clear.setFill()
            rightBubblePath.fill()

            // Right Text Position
            (rightText as NSString).draw(
                at: CGPoint(
                    x: Layout.leftBubblePadding + leftBubbleWidth + Layout.spacing + Layout.horizontalPadding,
                    y: (bubbleHeight - rightTextSize.height) / 2
                ),
                withAttributes: rightAttributes
            )
        }
    }
}
