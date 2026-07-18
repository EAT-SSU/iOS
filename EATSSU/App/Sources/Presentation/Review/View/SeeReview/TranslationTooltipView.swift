//
//  TranslationTooltipView.swift
//  EATSSU
//
//  Created by 황상환 on 7/18/26.
//

import UIKit
import SnapKit

import EATSSUDesign

/// AI 번역 유의사항 툴팁 (ⓘ 아이콘 탭 시 노출)
///
/// 닫기 버튼 없이 바깥 영역 탭·스크롤·화면 이동 등 다른 인터랙션이 발생하면 자동으로 닫힌다.
final class TranslationTooltipView: UIView {

    // MARK: - Properties

    /// 컨테이너에 붙여둔 바깥 탭 감지 제스처 (툴팁 제거 시 함께 정리)
    private weak var outsideTapGesture: UITapGestureRecognizer?

    // MARK: - UI Components

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 12)
        label.textColor = .gray600
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Configuration

    private func setupUI() {
        backgroundColor = .gray100
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray300.cgColor

        addSubviews(messageLabel)
    }

    private func setLayout() {
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }

    // MARK: - Lifecycle

    override func removeFromSuperview() {
        if let outsideTapGesture {
            superview?.removeGestureRecognizer(outsideTapGesture)
        }
        super.removeFromSuperview()
    }

    // MARK: - Actions

    /// 툴팁 바깥을 탭하면 닫는다 (cancelsTouchesInView = false라 원래 탭 동작은 그대로 전달됨)
    @objc
    private func handleOutsideTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        if !bounds.contains(location) {
            removeFromSuperview()
        }
    }

    // MARK: - Public Methods

    /// 컨테이너에 떠 있는 툴팁을 모두 닫는다.
    static func dismissAll(in containerView: UIView) {
        containerView.subviews
            .compactMap { $0 as? TranslationTooltipView }
            .forEach { $0.removeFromSuperview() }
    }

    /// anchorView(ⓘ 아이콘) 위쪽에 툴팁을 띄운다. 기존 툴팁은 제거.
    /// - Parameter message: 표시할 문구 (기본값: AI 번역 유의사항)
    static func show(
        in containerView: UIView,
        from anchorView: UIView,
        message: String = TextLiteral.Review.translationDisclaimer
    ) {
        dismissAll(in: containerView)

        let tooltip = TranslationTooltipView()
        tooltip.messageLabel.text = message
        containerView.addSubview(tooltip)

        let outsideTap = UITapGestureRecognizer(target: tooltip, action: #selector(handleOutsideTap(_:)))
        outsideTap.cancelsTouchesInView = false
        containerView.addGestureRecognizer(outsideTap)
        tooltip.outsideTapGesture = outsideTap

        let anchorFrame = anchorView.convert(anchorView.bounds, to: containerView)

        // 한 줄에 다 들어가면 텍스트 폭에 맞추고, 화면 폭을 넘으면 자연스럽게 줄바꿈
        let maxWidth = containerView.bounds.width - 32
        var size = tooltip.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if size.width > maxWidth {
            size = tooltip.systemLayoutSizeFitting(
                CGSize(width: maxWidth, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            size.width = maxWidth
        }

        // 아이콘 위에 배치하되, 화면 밖으로 나가지 않도록 조정
        var originX = anchorFrame.midX - size.width / 2
        originX = max(16, min(originX, containerView.bounds.width - size.width - 16))

        var originY = anchorFrame.minY - size.height - 8
        if originY < containerView.safeAreaInsets.top {
            originY = anchorFrame.maxY + 8
        }

        tooltip.frame = CGRect(origin: CGPoint(x: originX, y: originY), size: size)
    }
}
