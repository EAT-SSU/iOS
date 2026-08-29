//
//  MapAppButtonBar.swift
//  EATSSU
//
//  Created by 황상환 on 8/29/26.
//

import UIKit

import SnapKit

import EATSSUDesign

/// 상세 시트 하단의 카카오맵 / 네이버지도 이동 버튼 바
final class MapAppButtonBar: BaseUIView {

    // MARK: - Constants

    enum Layout {
        static let height: CGFloat = 56
        /// 시트 컨텐츠와 버튼 바 사이 최소 간격
        static let topSpacing: CGFloat = 6
        /// 버튼 바와 safe area 하단 사이 간격
        static let bottomInset: CGFloat = 10
        /// 시트 높이 계산 시 버튼 바가 차지하는 총 영역
        static var totalArea: CGFloat { topSpacing + height + bottomInset }
    }

    // MARK: - Properties

    var onKakaoMapTap: (() -> Void)?
    var onNaverMapTap: (() -> Void)?

    // MARK: - UI Components

    private let kakaoMapButton = UIButton()
    private let naverMapButton = UIButton()
    private let divider = UIView()

    // MARK: - View Setup

    override func configureUI() {
        kakaoMapButton.configuration = Self.makeButtonConfiguration(
            image: EATSSUDesignAsset.Images.kakaoMapLogo.image,
            title: TextLiteral.Map.kakaoMap
        )
        kakaoMapButton.addTarget(self, action: #selector(kakaoMapButtonTapped), for: .touchUpInside)

        naverMapButton.configuration = Self.makeButtonConfiguration(
            image: EATSSUDesignAsset.Images.naverMapLogo.image,
            title: TextLiteral.Map.naverMap
        )
        naverMapButton.addTarget(self, action: #selector(naverMapButtonTapped), for: .touchUpInside)

        divider.backgroundColor = EATSSUDesignColors.Color.gray300

        addSubviews(kakaoMapButton, naverMapButton, divider)
    }

    override func setLayout() {
        snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }

        kakaoMapButton.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.trailing.equalTo(snp.centerX)
        }

        naverMapButton.snp.makeConstraints {
            $0.trailing.top.bottom.equalToSuperview()
            $0.leading.equalTo(snp.centerX)
        }

        divider.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(1)
            $0.height.equalTo(16)
        }
    }

    // MARK: - Actions

    @objc private func kakaoMapButtonTapped() {
        onKakaoMapTap?()
    }

    @objc private func naverMapButtonTapped() {
        onNaverMapTap?()
    }

    // MARK: - Helpers

    /// 지도 앱 이동 버튼 공통 Configuration 생성
    private static func makeButtonConfiguration(image: UIImage, title: String) -> UIButton.Configuration {
        var config = UIButton.Configuration.plain()
        config.image = image
        config.imagePadding = 6
        config.baseForegroundColor = .label
        config.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer([.font: UIFont.body2])
        )
        return config
    }
}
