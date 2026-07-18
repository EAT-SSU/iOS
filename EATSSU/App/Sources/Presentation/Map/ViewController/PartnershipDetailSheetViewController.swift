//
//  PartnershipDetailSheetViewController.swift
//  EATSSU
//
//  Created by 황상환 on 7/2/25.
//

import UIKit

import SnapKit

import EATSSUDesign

final class PartnershipDetailSheetViewController: BaseViewController {

    // MARK: - Properties

    private let partnership: PartnershipDTO

    // MARK: - UI Components

    private let storeNameLabel = UILabel()
    private let typeStackView = UIStackView()
    private let typeIconImageView = UIImageView()
    private let typeTextLabel = UILabel()
    private let infoListStackView = UIStackView()
    private let mapButtonBarView = UIView()
    private let kakaoMapButton = UIButton()
    private let naverMapButton = UIButton()
    private let mapButtonDivider = UIView()

    // MARK: - Init

    init(partnership: PartnershipDTO) {
        self.partnership = partnership
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - View Setup

    override func configureUI() {
        view.backgroundColor = .white

        storeNameLabel.font = .header2
        storeNameLabel.textColor = .label

        typeIconImageView.contentMode = .scaleAspectFit
        typeIconImageView.snp.makeConstraints { $0.width.height.equalTo(18) }

        typeTextLabel.font = .body2
        typeTextLabel.textColor = .gray

        typeStackView.axis = .horizontal
        typeStackView.alignment = .center
        typeStackView.spacing = 4
        typeStackView.addArrangedSubview(typeIconImageView)
        typeStackView.addArrangedSubview(typeTextLabel)

        infoListStackView.axis = .vertical
        infoListStackView.spacing = 0
        infoListStackView.alignment = .fill
        infoListStackView.distribution = .fill
        infoListStackView.isLayoutMarginsRelativeArrangement = true
        infoListStackView.layoutMargins = .init(top: 10, left: 0, bottom: 10, right: 0)

        kakaoMapButton.configuration = makeMapButtonConfiguration(
            image: EATSSUDesignAsset.Images.kakaoMapLogo.image,
            title: TextLiteral.Map.kakaoMap
        )
        kakaoMapButton.addTarget(self, action: #selector(kakaoMapButtonTapped), for: .touchUpInside)

        naverMapButton.configuration = makeMapButtonConfiguration(
            image: EATSSUDesignAsset.Images.naverMapLogo.image,
            title: TextLiteral.Map.naverMap
        )
        naverMapButton.addTarget(self, action: #selector(naverMapButtonTapped), for: .touchUpInside)

        mapButtonDivider.backgroundColor = EATSSUDesignColors.Color.gray200

        [kakaoMapButton, naverMapButton, mapButtonDivider].forEach {
            mapButtonBarView.addSubview($0)
        }

        [storeNameLabel, typeStackView, infoListStackView, mapButtonBarView].forEach {
            view.addSubview($0)
        }
    }

    override func setLayout() {
        storeNameLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        typeStackView.snp.makeConstraints {
            $0.top.equalTo(storeNameLabel.snp.bottom).offset(4)
            $0.leading.equalTo(storeNameLabel)
        }

        infoListStackView.snp.makeConstraints {
            $0.top.equalTo(typeStackView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        mapButtonBarView.snp.makeConstraints {
            $0.top.equalTo(infoListStackView.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }

        kakaoMapButton.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.trailing.equalTo(mapButtonBarView.snp.centerX)
        }

        naverMapButton.snp.makeConstraints {
            $0.trailing.top.bottom.equalToSuperview()
            $0.leading.equalTo(mapButtonBarView.snp.centerX)
        }

        mapButtonDivider.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(1)
            $0.height.equalTo(16)
        }
    }

    // MARK: - Data Config

    override func viewDidLoad() {
        super.viewDidLoad()
        configureData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        logScreenView(screenID: FirebaseScreenID.Map.map2)
    }

    /// 매장 정보와 제휴 내용을 화면에 반영
    private func configureData() {
        storeNameLabel.text = partnership.storeName

        switch partnership.restaurantType {
        case "RESTAURANT":
            typeIconImageView.image = EATSSUDesignAsset.Images.restaurantPin.image
            typeTextLabel.text = TextLiteral.Map.restaurant
        case "CAFE":
            typeIconImageView.image = EATSSUDesignAsset.Images.cafePin.image
            typeTextLabel.text = TextLiteral.Map.cafe
        case "PUB":
            typeIconImageView.image = EATSSUDesignAsset.Images.pubPin.image
            typeTextLabel.text = TextLiteral.Map.pub
        default:
            typeIconImageView.image = EATSSUDesignAsset.Images.restaurantPin.image
            typeTextLabel.text = partnership.restaurantType
        }

        for (index, info) in partnership.partnershipInfos.enumerated() {
            let isLast = index == partnership.partnershipInfos.count - 1
            let card = makeInfoCard(info: info, isLast: isLast)
            infoListStackView.addArrangedSubview(card)
        }
    }

    // MARK: - UI Helpers

    /// 제휴 content 갯수에 따라 유동적으로 Height 측정
    func calculatePreferredHeight() -> CGFloat {
        view.layoutIfNeeded()
        let contentHeight = mapButtonBarView.frame.maxY
        let bottomPadding: CGFloat = view.safeAreaInsets.bottom + 10

        return contentHeight + bottomPadding
    }

    /// 지도 앱 이동 버튼 공통 Configuration 생성
    private func makeMapButtonConfiguration(image: UIImage, title: String) -> UIButton.Configuration {
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
    
    /// 제휴 정보 카드 뷰 생성
    private func makeInfoCard(info: PartnershipInfoDTO, isLast: Bool) -> UIView {
        let labelText = info.collegeName ?? info.departmentName ?? TextLiteral.Map.noDepartmentInfo
        
        let start = String(info.startDate.dropFirst(2))
        let end = String(info.endDate.dropFirst(2))

        let fullText = "\(labelText)  \(start) ~ \(end)"
        let attrText = NSMutableAttributedString(string: fullText)

        let collegeRange = (fullText as NSString).range(of: labelText)
        let dateRange = (fullText as NSString).range(of: "\(start) ~ \(end)")

        attrText.addAttributes([
            .font: UIFont.body2,
            .foregroundColor: UIColor.label
        ], range: collegeRange)

        attrText.addAttributes([
            .font: UIFont.caption2,
            .foregroundColor: EATSSUDesignColors.Color.gray700,
            .baselineOffset: +1
        ], range: dateRange)

        let titleDateLabel = UILabel()
        titleDateLabel.attributedText = attrText

        let descriptionLabel = UILabel()
        descriptionLabel.font = .body3
        descriptionLabel.textColor = EATSSUDesignColors.Color.gray700
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = info.description

        let contentStack = UIStackView(arrangedSubviews: [titleDateLabel, descriptionLabel])
        contentStack.axis = .vertical
        contentStack.spacing = 4

        let separator = UIView()
        separator.backgroundColor = EATSSUDesignColors.Color.gray200
        separator.isHidden = isLast
        separator.snp.makeConstraints {
            $0.height.equalTo(1)
        }

        let container = UIStackView(arrangedSubviews: [contentStack, separator])
        container.axis = .vertical
        container.spacing = 10

        let paddedContainer = UIView()
        paddedContainer.addSubview(container)
        container.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
        }

        return paddedContainer
    }

    // MARK: - Actions

    /// 카카오맵 장소 상세 페이지로 이동
    /// 서버 제공 URL 우선 → 없으면 로컬 API 매칭 → 실패 시 좌표 핀 폴백
    @objc private func kakaoMapButtonTapped() {
        // 서버가 준 place URL(place.map.kakao.com/{id})에서 id를 추출해 앱 스킴으로 연결
        if let urlString = partnership.kakaoMapUrl,
           let webURL = URL(string: urlString),
           Int(webURL.lastPathComponent) != nil {
            let appURL = URL(string: "kakaomap://place?id=\(webURL.lastPathComponent)")
            openMapApp(appURL: appURL, fallbackURL: webURL)
            return
        }

        KakaoLocalService.shared.searchNearestPlace(
            keyword: partnership.storeName,
            latitude: partnership.latitude,
            longitude: partnership.longitude
        ) { [weak self] place in
            guard let self else { return }

            if let place {
                let appURL = URL(string: "kakaomap://place?id=\(place.id)")
                self.openMapApp(appURL: appURL, fallbackURL: URL(string: place.placeURL))
            } else {
                self.openKakaoMapByCoordinate()
            }
        }
    }

    /// 카카오맵 좌표 핀으로 이동 (미설치 시 카카오맵 웹)
    private func openKakaoMapByCoordinate() {
        let appURL = URL(string: "kakaomap://look?p=\(partnership.latitude),\(partnership.longitude)")
        let encodedName = partnership.storeName
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let webURL = URL(
            string: "https://map.kakao.com/link/map/\(encodedName),\(partnership.latitude),\(partnership.longitude)"
        )
        openMapApp(appURL: appURL, fallbackURL: webURL)
    }

    /// 네이버지도 플레이스로 이동
    /// 서버 제공 URL 우선(유니버설 링크로 앱/웹 자동 분기) → 없으면 정제된 상호명 검색 폴백
    @objc private func naverMapButtonTapped() {
        if let urlString = partnership.naverMapUrl,
           let url = URL(string: urlString) {
            UIApplication.shared.open(url)
            return
        }

        KakaoLocalService.shared.searchNearestPlace(
            keyword: partnership.storeName,
            latitude: partnership.latitude,
            longitude: partnership.longitude
        ) { [weak self] place in
            guard let self else { return }
            self.openNaverMapSearch(query: place?.placeName ?? self.partnership.storeName)
        }
    }

    private func openNaverMapSearch(query: String) {
        var components = URLComponents(string: "nmap://search")
        components?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "appname", value: Bundle.main.bundleIdentifier ?? "")
        ]
        let encodedQuery = query
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        let webURL = URL(string: "https://map.naver.com/p/search/\(encodedQuery)")
        openMapApp(appURL: components?.url, fallbackURL: webURL)
    }

    private func openMapApp(appURL: URL?, fallbackURL: URL?) {
        if let appURL, UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else if let fallbackURL {
            UIApplication.shared.open(fallbackURL)
        }
    }

}
