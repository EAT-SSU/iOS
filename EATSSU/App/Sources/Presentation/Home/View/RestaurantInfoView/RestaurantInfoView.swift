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

    let restaurantImage: UIImageView = {
        let imageView = UIImageView(image: EATSSUDesignAsset.Images.restaurantImage.image)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()

    var restaurantNameLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.Home.studentRestaurant
        label.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 18)
        return label
    }()

    private let locationTitleLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.Home.restaurantLocation
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 13)
        label.textColor = .gray500
        return label
    }()

    private var locationLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.Home.soongsilUniversity
        label.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 16)
        label.numberOfLines = 0
        return label
    }()

    private let openingTimeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.Home.businessHour
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 13)
        label.textColor = .gray500
        return label
    }()

    private let openingTimeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 16)
        return label
    }()

    private let ectTitleLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.Home.note
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 13)
        label.textColor = .gray500
        return label
    }()

    private let ectLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 16)
        return label
    }()

    // MARK: - Functions

    override func configureUI() {
        addSubviews(restaurantNameLabel,
                    restaurantImage,
                    locationTitleLabel,
                    locationLabel,
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
        restaurantImage.snp.makeConstraints {
            $0.top.equalTo(restaurantNameLabel.snp.bottom).offset(28)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(232)
        }
        locationTitleLabel.snp.makeConstraints {
            $0.top.equalTo(restaurantImage.snp.bottom).offset(28)
            $0.leading.equalToSuperview().offset(20)
        }
        locationLabel.snp.makeConstraints {
            $0.top.equalTo(locationTitleLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        openingTimeTitleLabel.snp.makeConstraints {
            $0.top.equalTo(locationLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(20)
        }
        openingTimeLabel.snp.makeConstraints {
            $0.top.equalTo(openingTimeTitleLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        ectTitleLabel.snp.makeConstraints {
            $0.top.equalTo(openingTimeLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(20)
        }
        ectLabel.snp.makeConstraints {
            $0.top.equalTo(ectTitleLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
    }

    func bind(data: RestaurantInfoData) {
        restaurantNameLabel.text = data.name
        setValueText(data.location, on: locationLabel)
        setValueText(data.time, on: openingTimeLabel)
        setValueText(data.etc, on: ectLabel)
        loadImage(with: data.image, into: restaurantImage)
    }

    func loadImage(with urlString: String, into imageView: UIImageView) {
        if let url = URL(string: urlString) {
            imageView.kf.setImage(with: url)
        } else {
            print("Invalid URL string.")
        }
    }

    /// 여러 줄 값 레이블에 줄 간격을 유지한 채 텍스트를 적용
    private func setValueText(_ text: String, on label: UILabel) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        label.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: EATSSUDesignFontFamily.Pretendard.medium.font(size: 16)
            ]
        )
    }
}
