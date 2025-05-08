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

        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.minimumPressDuration = 0
        self.addGestureRecognizer(tapGesture)
    }

    override func setLayout() {
        backgroundWrapper.snp.makeConstraints { $0.edges.equalToSuperview() }

        contentStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.horizontalEdges.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview().inset(5)
        }

        nameLabel.snp.makeConstraints { $0.width.equalTo(210) }
        priceLabel.snp.makeConstraints { $0.width.equalTo(47) }
        ratingLabel.snp.makeConstraints { $0.width.equalTo(25) }
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

    @objc private func handleTap(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            backgroundWrapper.backgroundColor = UIColor.gray300
        case .ended:
            backgroundWrapper.backgroundColor = .clear
            guard let indexPath else { return }
            onTap?(indexPath)
        case .cancelled, .failed:
            backgroundWrapper.backgroundColor = .clear
        default:
            break
        }
    }
}
