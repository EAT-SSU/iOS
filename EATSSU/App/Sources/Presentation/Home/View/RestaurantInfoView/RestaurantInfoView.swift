//
//  RestaurantInfoView.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/23.
//

import UIKit

import MapKit
import SnapKit

import EATSSUDesign

final class RestaurantInfoView: BaseUIView {
    // MARK: - UI Components

    let restaurantImage = UIImageView(image: EATSSUDesignAsset.Images.restaurantImage.image)

    var restaurantNameLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.Home.studentRestaurant
        label.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 20)
        return label
    }()

    private let locationTitleLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.Home.restaurantLocation
        label.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 18)
        return label
    }()

    private let imageTitleLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.Home.restaurantPicture
        label.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 18)
        return label
    }()

    private var locationLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.Home.soongsilUniversity
        label.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 16)
        return label
    }()

    private let openingTimeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.Home.businessHour
        label.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 18)
        return label
    }()

    private let openingTimeLabel: UILabel = {
        let label = UILabel()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        label.attributedText = NSAttributedString(
            string: "08:00~09:30\n11:00~14:00\n17:00~18:30",
            attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle]
        )
        label.numberOfLines = 0
        label.textAlignment = .right
        label.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 16)
        return label
    }()

    private let ectTitleLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.Home.note
        label.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 18)
        return label
    }()

    private let ectLabel: UILabel = {
        let label = UILabel()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        label.attributedText = NSAttributedString(
            string: TextLiteral.Home.dodamEtc,
            attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle]
        )
        label.numberOfLines = 0
        label.textAlignment = .right
        label.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 16)
        return label
    }()

    // MARK: - Functions

    override func configureUI() {
        addSubviews(restaurantNameLabel,
                    locationTitleLabel,
                    locationLabel,
                    imageTitleLabel,
                    restaurantImage,
                    openingTimeTitleLabel,
                    openingTimeLabel,
                    ectTitleLabel,
                    ectLabel)
    }

    override func setLayout() {
        restaurantNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(38)
            $0.centerX.equalToSuperview()
        }
        locationTitleLabel.snp.makeConstraints {
            $0.top.equalTo(restaurantNameLabel.snp.bottom).offset(56)
            $0.leading.equalToSuperview().offset(21)
        }
        locationLabel.snp.makeConstraints {
            $0.top.equalTo(locationTitleLabel)
            $0.trailing.equalToSuperview().inset(21)
        }
        imageTitleLabel.snp.makeConstraints {
            $0.top.equalTo(locationTitleLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(21)
        }
        restaurantImage.snp.makeConstraints {
            $0.top.equalTo(imageTitleLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(21)
            $0.height.equalTo(232)
        }
        openingTimeTitleLabel.snp.makeConstraints {
            $0.top.equalTo(restaurantImage.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(21)
        }
        openingTimeLabel.snp.makeConstraints {
            $0.top.equalTo(openingTimeTitleLabel)
            $0.trailing.equalToSuperview().inset(21)
            $0.width.equalTo(250)
        }
        ectTitleLabel.snp.makeConstraints {
            $0.top.equalTo(openingTimeLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(21)
        }
        ectLabel.snp.makeConstraints {
            $0.top.equalTo(ectTitleLabel)
            $0.trailing.equalToSuperview().inset(21)
        }
    }

    func bind(data: RestaurantInfoData) {
        restaurantNameLabel.text = data.name
        locationLabel.text = data.location
        openingTimeLabel.text = data.time
        ectLabel.text = data.etc
        loadImage(with: data.image, into: restaurantImage)
    }

    func loadImage(with urlString: String, into imageView: UIImageView) {
        if let url = URL(string: urlString) {
            imageView.kf.setImage(with: url)
        } else {
            print("Invalid URL string.")
        }
    }
}
