//
//  RestaurantMenuItemView.swift
//  EATSSU
//
//  Created by 황상환 on 4/6/25.
//

import UIKit

import SnapKit

final class RestaurantMenuItemView: BaseUIView {

    var indexPath: IndexPath?
    var onTap: ((IndexPath) -> Void)?

    private let backgroundWrapper = UIView()

    private let nameLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = .body3
    }

    private let priceLabel = UILabel().then {
        $0.font = .body3
        $0.textAlignment = .center
    }

    private let ratingLabel = UILabel().then {
        $0.font = .body3
        $0.textAlignment = .center
    }

    private let contentStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 24
    }

    override func configureUI() {
        addSubview(backgroundWrapper)
        backgroundWrapper.addSubview(contentStackView)
        backgroundWrapper.layer.cornerRadius = 0
        backgroundWrapper.clipsToBounds = true
        
        contentStackView.addArrangedSubviews([nameLabel, priceLabel, ratingLabel])
    }

    override func setLayout() {
        backgroundWrapper.snp.makeConstraints { $0.edges.equalToSuperview() }

        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12))
        }

        nameLabel.snp.makeConstraints { $0.width.equalTo(210).priority(.high) }
        priceLabel.snp.makeConstraints { $0.width.equalTo(47).priority(.high) }
        ratingLabel.snp.makeConstraints { $0.width.equalTo(25).priority(.high) }
    }

    func bind(_ model: MenuTypeInfo) {
        switch model {
        case let .change(data):
            nameLabel.text = data.briefMenus.map(\ .name).joined(separator: "+")
            priceLabel.text = data.price?.formattedWithCommas ?? ""
            ratingLabel.text = data.rating != nil ? String(format: "%.1f", data.rating!) : "-"
        case let .fix(data):
            nameLabel.text = data.name
            priceLabel.text = data.price?.formattedWithCommas ?? ""
            ratingLabel.text = data.rating != nil ? String(format: "%.1f", data.rating!) : "-"
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        backgroundWrapper.backgroundColor = UIColor.gray300
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        backgroundWrapper.backgroundColor = .clear
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        backgroundWrapper.backgroundColor = .clear

        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if bounds.contains(location), let indexPath = indexPath {
            onTap?(indexPath)
        }
    }

}
