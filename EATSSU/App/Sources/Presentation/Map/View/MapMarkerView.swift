//
//  MapMarkerView.swift
//  EATSSU
//
//  Created by 황상환 on 7/2/25.
//

import UIKit

import EATSSUDesign

final class MapMarkerView: BaseUIView {

    // MARK: - UI Components

    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()

    // MARK: - Init

    init(icon: UIImage?, title: String) {
        super.init(frame: .zero)
        setup(icon: icon, title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Setup
    
    override func configureUI() {
        backgroundColor = .white
        layer.cornerRadius = 13
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray3.cgColor

        iconImageView.contentMode = .scaleAspectFit
        addSubview(iconImageView)
        addSubview(titleLabel)
    }

    // MARK: - Setup

    private func setup(icon: UIImage?, title: String) {
        iconImageView.image = icon

        titleLabel.text = title
        titleLabel.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 10)
        titleLabel.textColor = .black
    }

    // MARK: - Layout

    override var intrinsicContentSize: CGSize {
        let labelSize = titleLabel.intrinsicContentSize
        let leftPadding: CGFloat   = 3
        let iconSize: CGFloat      = 20
        let textSpacing: CGFloat   = 3
        let rightPadding: CGFloat  = 7
        let height: CGFloat        = 25

        let width = leftPadding + iconSize + textSpacing + labelSize.width + rightPadding
        return CGSize(width: width, height: height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let h = bounds.height
        let leftRightPadding: CGFloat = 3
        let iconSize: CGFloat = 20
        let textSpacing: CGFloat = 3

        iconImageView.frame = CGRect(
            x: leftRightPadding,
            y: (h - iconSize) / 2,
            width: iconSize,
            height: iconSize
        )

        let labelSize = titleLabel.intrinsicContentSize
        titleLabel.frame = CGRect(
            x: iconImageView.frame.maxX + textSpacing,
            y: (h - labelSize.height) / 2,
            width: labelSize.width,
            height: labelSize.height
        )
    }

    // MARK: - Convert View to Image

    func toImage() -> UIImage {
        layoutIfNeeded()
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return renderer.image { ctx in
            layer.render(in: ctx.cgContext)
        }
    }
}
