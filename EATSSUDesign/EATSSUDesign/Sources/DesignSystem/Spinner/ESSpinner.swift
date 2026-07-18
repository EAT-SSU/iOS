//
//  ESSpinner.swift
//  EATSSUDesign
//
//  Created by 황상환 on 7/18/26.
//

import UIKit

/// 원호(arc)가 회전하는 커스텀 로딩 스피너
///
/// UIActivityIndicatorView 대체용. 원의 일정 구간만 채워진 호가 회전한다.
public final class ESSpinner: UIView {

    // MARK: - Properties

    /// 호 색상
    public var color: UIColor = .aiAccent {
        didSet { arcLayer.strokeColor = color.cgColor }
    }

    /// 호 두께
    public var lineWidth: CGFloat = 2 {
        didSet {
            arcLayer.lineWidth = lineWidth
            setNeedsLayout()
        }
    }

    /// 원 둘레 대비 호가 채워지는 비율 (0~1)
    public var arcRatio: CGFloat = 0.75 {
        didSet { arcLayer.strokeEnd = arcRatio }
    }

    /// stopAnimating() 시 자동 숨김 여부
    public var hidesWhenStopped: Bool = true

    public private(set) var isAnimating: Bool = false

    private let arcLayer = CAShapeLayer()
    private static let rotationAnimationKey = "es.spinner.rotation"

    // MARK: - Initialization

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override public func layoutSubviews() {
        super.layoutSubviews()

        arcLayer.frame = bounds

        let radius = (min(bounds.width, bounds.height) - lineWidth) / 2
        arcLayer.path = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: .pi * 3 / 2,
            clockwise: true
        ).cgPath
    }

    /// 화면 재진입 시 끊긴 애니메이션 복구 (CAAnimation은 오프스크린에서 제거됨)
    override public func didMoveToWindow() {
        super.didMoveToWindow()

        if window != nil, isAnimating {
            addRotationAnimation()
        }
    }

    // MARK: - Public Methods

    public func startAnimating() {
        isAnimating = true
        isHidden = false
        addRotationAnimation()
    }

    public func stopAnimating() {
        isAnimating = false
        arcLayer.removeAnimation(forKey: Self.rotationAnimationKey)

        if hidesWhenStopped {
            isHidden = true
        }
    }

    // MARK: - Private Methods

    private func setupLayer() {
        arcLayer.fillColor = UIColor.clear.cgColor
        arcLayer.strokeColor = color.cgColor
        arcLayer.lineWidth = lineWidth
        arcLayer.lineCap = .round
        arcLayer.strokeStart = 0
        arcLayer.strokeEnd = arcRatio
        layer.addSublayer(arcLayer)

        isHidden = hidesWhenStopped
    }

    private func addRotationAnimation() {
        guard arcLayer.animation(forKey: Self.rotationAnimationKey) == nil else { return }

        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 1
        rotation.repeatCount = .infinity
        rotation.isRemovedOnCompletion = false
        arcLayer.add(rotation, forKey: Self.rotationAnimationKey)
    }
}
