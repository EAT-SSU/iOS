//
//  FestivalInfoBannerView.swift
//  EATSSU
//
//  Created by 황상환 on 9/13/26.
//

import UIKit

import SnapKit

import EATSSUDesign

/// 축제 제휴 안내 말풍선. 도움말 아이콘 왼쪽에 붙고 꼬리가 아이콘을 향한다
final class FestivalInfoBannerView: BaseUIView {

    // MARK: - Constants

    enum Layout {
        static let height: CGFloat = 48
        static let cornerRadius: CGFloat = 24
        /// 아이콘을 향하는 꼬리 크기 (디자인 실측)
        static let tailWidth: CGFloat = 6
        static let tailHeight: CGFloat = 9
        static let horizontalPadding: CGFloat = 14
        static let lineSpacing: CGFloat = 3
    }

    // MARK: - UI Components

    private let bubbleLayer = CAShapeLayer()
    private let messageLabel = UILabel()

    // MARK: - View Setup

    override func configureUI() {
        backgroundColor = .clear
        isUserInteractionEnabled = true

        bubbleLayer.fillColor = UIColor.festivalPrimary.withAlphaComponent(0.9).cgColor
        layer.insertSublayer(bubbleLayer, at: 0)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = Layout.lineSpacing
        messageLabel.numberOfLines = 2
        messageLabel.attributedText = NSAttributedString(
            string: TextLiteral.Map.festivalBannerMessage,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.caption2,
                .foregroundColor: UIColor.white
            ]
        )

        addSubview(messageLabel)
    }

    override func setLayout() {
        snp.makeConstraints { $0.height.equalTo(Layout.height) }

        messageLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Layout.horizontalPadding)
            // 꼬리 폭만큼 오른쪽 여백을 더 둔다
            $0.trailing.equalToSuperview().inset(Layout.horizontalPadding + Layout.tailWidth)
            $0.centerY.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bubbleLayer.path = Self.bubblePath(in: bounds).cgPath
    }

    // MARK: - Drawing

    /// 둥근 말풍선 + 오른쪽 중앙의 꼬리
    private static func bubblePath(in bounds: CGRect) -> UIBezierPath {
        let bodyWidth = max(bounds.width - Layout.tailWidth, 0)
        let body = CGRect(x: 0, y: 0, width: bodyWidth, height: bounds.height)
        let path = UIBezierPath(roundedRect: body, cornerRadius: Layout.cornerRadius)

        let centerY = bounds.midY
        let tail = UIBezierPath()
        tail.move(to: CGPoint(x: bodyWidth - 1, y: centerY - Layout.tailHeight / 2))
        tail.addLine(to: CGPoint(x: bounds.maxX, y: centerY))
        tail.addLine(to: CGPoint(x: bodyWidth - 1, y: centerY + Layout.tailHeight / 2))
        tail.close()
        path.append(tail)

        return path
    }
}
