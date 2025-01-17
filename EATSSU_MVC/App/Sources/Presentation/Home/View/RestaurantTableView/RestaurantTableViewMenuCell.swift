//
//  RestaurantTableViewMenuCell.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/08/09.
//

import UIKit

import SnapKit

class RestaurantTableViewMenuCell: BaseTableViewCell {
    // MARK: - Properties

    static let identifier = "RestaurantTableViewMenuCell"

    var model: MenuTypeInfo? {
        didSet {
            if let model = model {
                bind(model)
            }
        }
    }

    // MARK: - UI Components

    private let contentStackView = UIStackView()
    private var nameLabel = UILabel()
    private var priceLabel = UILabel()
    private var ratingLabel = UILabel()

    // MARK: - Life Cycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setViewProperties()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        priceLabel.text = nil
        ratingLabel.text = nil
    }

    // MARK: - Functions

    override func configureUI() {
        contentView.addSubview(contentStackView)
        contentStackView.addArrangedSubviews([nameLabel,
                                              priceLabel,
                                              ratingLabel])
    }

    override func setLayout() {
        contentStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.horizontalEdges.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().inset(5)
        }
        nameLabel.snp.makeConstraints {
            $0.width.equalTo(210)
        }
        priceLabel.snp.makeConstraints {
            $0.width.equalTo(47)
        }
        ratingLabel.snp.makeConstraints {
            $0.width.equalTo(25)
        }
    }
}

extension RestaurantTableViewMenuCell {
    private func setViewProperties() {
        contentStackView.do {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = 24
        }
        nameLabel.do {
            $0.font = .body3
            $0.numberOfLines = 0
            $0.lineBreakMode = .byWordWrapping
        }
        priceLabel.do {
            $0.font = .body3
            $0.textAlignment = .center
        }
        ratingLabel.do {
            $0.font = .body3
            $0.textAlignment = .center
        }
    }

    public func bind(_ model: MenuTypeInfo) {
        switch model {
        case let .change(data):
            priceLabel.text = data.price != nil ? data.price?.formattedWithCommas : ""

            if data.rating != nil {
                let formatRating = String(format: "%.1f", data.rating ?? 0)
                ratingLabel.text = formatRating
            } else {
                ratingLabel.text = TextLiteral.Home.emptyRating
            }

            if data.briefMenus.isEmpty {
                // vc에서 이미 필터링되어 의미 없음. 리팩 필요
                nameLabel.text = "제공되는 메뉴가 없습니다"
            } else {
                nameLabel.text = data.briefMenus.map { $0.name }.joined(separator: "+")
            }

        case let .fix(data):
            if let price = data.price {
                priceLabel.text = price.formattedWithCommas
                let formatRating = String(format: "%.1f", data.rating ?? 0)
                ratingLabel.text = formatRating != "0.0" ? formatRating : "-"
                nameLabel.text = data.name
            } else {
                nameLabel.text = "제공되는 메뉴가 없습니다"
            }
        }
    }
}
