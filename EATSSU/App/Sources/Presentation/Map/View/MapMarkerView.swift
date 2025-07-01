//
//  MapMarkerView.swift
//  EATSSU
//
//  Created by 황상환 on 7/2/25.
//

import UIKit

import EATSSUDesign

final class MapMarkerView: UIView {

    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()

    init(icon: UIImage?, title: String) {
        super.init(frame: .zero)
        setupUI(icon: icon, title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(icon: UIImage?, title: String) {
        backgroundColor = .white
        layer.cornerRadius = 13
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray3.cgColor

        iconImageView.image = icon
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.snp.makeConstraints { $0.size.equalTo(20) }

        titleLabel.text = title
        titleLabel.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 10)
        titleLabel.textColor = .black

        let hStack = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.spacing = 2
        hStack.layoutMargins = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 8)
        hStack.isLayoutMarginsRelativeArrangement = true

        addSubview(hStack)
        hStack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    func toImage() -> UIImage {
        layoutIfNeeded()
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return renderer.image { ctx in
            layer.render(in: ctx.cgContext)
        }
    }

}
