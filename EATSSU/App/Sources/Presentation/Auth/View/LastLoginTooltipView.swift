//
//  LastLoginTooltipView.swift
//  EATSSU
//
//  Created by 황상환 2026/03/05.
//

import UIKit

import EATSSUDesign

/// 로그인 화면에서 "최근에 로그인했어요" 말풍선 툴팁을 표시하는 뷰
final class LastLoginTooltipView: UIView {

    enum ArrowDirection {
        /// 화살표가 아래를 가리킴 (Apple 버튼 위에 표시할 때)
        case down
        /// 화살표가 위를 가리킴 (Kakao 버튼 아래에 표시할 때)
        case up
    }

    // MARK: - Constants

    private enum Metric {
        static let arrowSize = CGSize(width: 12, height: 6)
        static let cornerRadius: CGFloat = 8
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 12
        static let fontSize: CGFloat = 12
    }

    // MARK: - Properties

    private let arrowDirection: ArrowDirection

    private let label: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.Auth.lastLoginTooltip
        label.textColor = .white
        label.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: Metric.fontSize)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Init

    init(arrowDirection: ArrowDirection) {
        self.arrowDirection = arrowDirection
        super.init(frame: .zero)
        backgroundColor = .clear
        isOpaque = false
        contentMode = .redraw
        addSubview(label)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        let arrowHeight = Metric.arrowSize.height
        let labelY: CGFloat
        switch arrowDirection {
        case .up:
            labelY = arrowHeight
        case .down:
            labelY = 0
        }

        label.frame = CGRect(
            x: Metric.horizontalPadding,
            y: labelY + Metric.verticalPadding,
            width: bounds.width - Metric.horizontalPadding * 2,
            height: bounds.height - arrowHeight - Metric.verticalPadding * 2
        )
    }

    override var intrinsicContentSize: CGSize {
        let labelSize = label.intrinsicContentSize
        let width = labelSize.width + Metric.horizontalPadding * 2
        let height = labelSize.height + Metric.verticalPadding * 2 + Metric.arrowSize.height
        return CGSize(width: width, height: height)
    }

    // MARK: - Drawing

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let arrowSize = Metric.arrowSize
        let cornerRadius = Metric.cornerRadius
        let fillColor = UIColor.gray700

        context.setFillColor(fillColor.cgColor)

        let bubbleRect: CGRect
        switch arrowDirection {
        case .up:
            bubbleRect = CGRect(x: 0, y: arrowSize.height, width: rect.width, height: rect.height - arrowSize.height)
        case .down:
            bubbleRect = CGRect(x: 0, y: 0, width: rect.width, height: rect.height - arrowSize.height)
        }

        let bubblePath = UIBezierPath(roundedRect: bubbleRect, cornerRadius: cornerRadius)
        bubblePath.fill()

        // 화살표 그리기
        let arrowPath = UIBezierPath()
        let arrowCenterX = rect.width / 2

        switch arrowDirection {
        case .up:
            let arrowTip = CGPoint(x: arrowCenterX, y: 0)
            let arrowLeft = CGPoint(x: arrowCenterX - arrowSize.width / 2, y: arrowSize.height)
            let arrowRight = CGPoint(x: arrowCenterX + arrowSize.width / 2, y: arrowSize.height)
            arrowPath.move(to: arrowTip)
            arrowPath.addLine(to: arrowRight)
            arrowPath.addLine(to: arrowLeft)
            arrowPath.close()
        case .down:
            let arrowTip = CGPoint(x: arrowCenterX, y: rect.height)
            let arrowLeft = CGPoint(x: arrowCenterX - arrowSize.width / 2, y: rect.height - arrowSize.height)
            let arrowRight = CGPoint(x: arrowCenterX + arrowSize.width / 2, y: rect.height - arrowSize.height)
            arrowPath.move(to: arrowTip)
            arrowPath.addLine(to: arrowRight)
            arrowPath.addLine(to: arrowLeft)
            arrowPath.close()
        }

        arrowPath.fill()
    }
}
