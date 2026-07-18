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
/// X 버튼 외에도 바깥 영역 탭·스크롤 등 다른 인터랙션이 발생하면 자동으로 닫힌다.
final class TranslationTooltipView: UIView {

    // MARK: - Properties

    /// 컨테이너에 붙여둔 바깥 탭 감지 제스처 (툴팁 제거 시 함께 정리)
    private weak var outsideTapGesture: UITapGestureRecognizer?

    // MARK: - UI Components

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.Review.translationDisclaimer
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 12)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(
            EATSSUDesignAsset.Images.icClose.image.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        button.tintColor = .gray500
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(touchedCloseButton), for: .touchUpInside)
        return button
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
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8

        addSubviews(messageLabel, closeButton)
    }

    private func setLayout() {
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }

        // X는 우상단 코너에 고정 (텍스트는 트레일링 여백 없이 전체 폭 사용)
        closeButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(6)
            make.width.height.equalTo(12)
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

    @objc
    private func touchedCloseButton() {
        removeFromSuperview()
    }

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
    static func show(in containerView: UIView, from anchorView: UIView) {
        dismissAll(in: containerView)

        let tooltip = TranslationTooltipView()
        containerView.addSubview(tooltip)

        let outsideTap = UITapGestureRecognizer(target: tooltip, action: #selector(handleOutsideTap(_:)))
        outsideTap.cancelsTouchesInView = false
        containerView.addGestureRecognizer(outsideTap)
        tooltip.outsideTapGesture = outsideTap

        let anchorFrame = anchorView.convert(anchorView.bounds, to: containerView)
        let maxWidth: CGFloat = 180
        let size = tooltip.systemLayoutSizeFitting(
            CGSize(width: maxWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

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
