//
//  ESSpinner.swift
//  EATSSUDesign
//
//  Created by 황상환 on 7/18/26.
//

import UIKit

/// 원호(arc)가 회전하는 커스텀 로딩 스피너
///
/// UIActivityIndicatorView 대체용. 연한 색 트랙 원 위에서 진한 색 호가 회전한다.
public final class ESSpinner: UIView {

    // MARK: - Properties

    /// 호 색상 (트랙은 이 색의 연한 버전으로 자동 적용)
    public var color: UIColor = .gray400 {
        didSet {
            arcLayer.strokeColor = color.cgColor
            updateTrackColor()
        }
    }

    /// 트랙(배경 원) 색상. nil이면 color의 25% 알파를 사용
    public var trackColor: UIColor? {
        didSet { updateTrackColor() }
    }

    /// 호 두께
    public var lineWidth: CGFloat = 2 {
        didSet {
            arcLayer.lineWidth = lineWidth
            trackLayer.lineWidth = lineWidth
            setNeedsLayout()
        }
    }

    /// 원 둘레 대비 호가 채워지는 비율 (0~1)
    public var arcRatio: CGFloat = 0.25 {
        didSet { arcLayer.strokeEnd = arcRatio }
    }

    /// stopAnimating() 시 자동 숨김 여부
    public var hidesWhenStopped: Bool = true

    public private(set) var isAnimating: Bool = false

    private let trackLayer = CAShapeLayer()
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

        trackLayer.frame = bounds
        arcLayer.frame = bounds

        let radius = (min(bounds.width, bounds.height) - lineWidth) / 2
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: .pi * 3 / 2,
            clockwise: true
        ).cgPath
        trackLayer.path = circlePath
        arcLayer.path = circlePath
    }

    /// 화면 재진입 시 끊긴 애니메이션 복구 (CAAnimation은 오프스크린에서 제거됨)
    override public func didMoveToWindow() {
        super.didMoveToWindow()

        if window != nil, isAnimating {
            addRotationAnimation()
        }
    }

    /// 앱이 백그라운드에 다녀오면 CAAnimation이 제거되므로 포그라운드 복귀 시 복구
    @objc
    private func handleWillEnterForeground() {
        if isAnimating {
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
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = lineWidth
        trackLayer.strokeStart = 0
        trackLayer.strokeEnd = 1
        layer.addSublayer(trackLayer)

        arcLayer.fillColor = UIColor.clear.cgColor
        arcLayer.strokeColor = color.cgColor
        arcLayer.lineWidth = lineWidth
        arcLayer.lineCap = .round
        arcLayer.strokeStart = 0
        arcLayer.strokeEnd = arcRatio
        layer.addSublayer(arcLayer)

        updateTrackColor()
        isHidden = hidesWhenStopped

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    private func updateTrackColor() {
        let resolved = trackColor ?? color.withAlphaComponent(0.25)
        trackLayer.strokeColor = resolved.cgColor
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
