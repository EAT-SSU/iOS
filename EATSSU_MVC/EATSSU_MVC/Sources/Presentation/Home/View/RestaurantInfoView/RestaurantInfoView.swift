//
//  RestaurantInfoView.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/23.
//

import UIKit

import MapKit
import SnapKit
import Then

final class RestaurantInfoView: BaseUIView {
    
    // MARK: - UI Components
    
    let restaurantImage = UIImageView(image: EATSSUAsset.Images.Version2.restaurantImage.image)
    
    var restaurantNameLabel = UILabel().then {
        $0.text = "학생 식당"
        $0.font = .header1
    }
    private let locationTitleLabel = UILabel().then {
        $0.text = "식당 위치"
        $0.font = .header2
    }
    private let imageTitleLabel = UILabel().then {
        $0.text = "식당 사진"
        $0.font = .header2
    }
    private var locationLabel = UILabel().then {
        $0.text = "숭실대학교"
        $0.font = .body1
    }
    private let openingTimeTitleLabel = UILabel().then {
        $0.text = "영업 시간"
        $0.font = .header2
    }
    private let openingTimeLabel = UILabel().then {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        let attributedString = NSAttributedString(string: "08:00~09:30\n11:00~14:00\n17:00~18:30",
                                                  attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        $0.attributedText = attributedString
        $0.numberOfLines = 0
        $0.textAlignment = .right
        $0.font = .body1
    }
    private let ectTitleLabel = UILabel().then {
        $0.text = "비고"
        $0.font = .header2
    }
    private let ectLabel = UILabel().then {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        let attributedString = NSAttributedString(string: "아시안푸드, 돈까스, 샐러드, 국밥 등\n카페",
                                                  attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        $0.attributedText = attributedString
        $0.numberOfLines = 0
        $0.textAlignment = .right
        $0.font = .body1
    }
    
    //MARK: - Functions
    
    override func configureUI() {
        self.addSubviews(restaurantNameLabel,
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
