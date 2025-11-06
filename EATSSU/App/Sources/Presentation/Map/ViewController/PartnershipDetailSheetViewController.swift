//
//  PartnershipDetailSheetViewController.swift
//  EATSSU
//
//  Created by 황상환 on 7/2/25.
//

import UIKit

import SnapKit
import FirebaseAnalytics

import EATSSUDesign

final class PartnershipDetailSheetViewController: BaseViewController {

    // MARK: - Properties

    private let storeName: String
    private let restaurantType: String
    private let partnershipInfos: [PartnershipInfoDTO]

    // MARK: - UI Components

    private let storeNameLabel = UILabel()
    private let typeStackView = UIStackView()
    private let typeIconImageView = UIImageView()
    private let typeTextLabel = UILabel()
    private let infoListStackView = UIStackView()

    // MARK: - Init

    init(storeName: String, restaurantType: String, partnershipInfos: [PartnershipInfoDTO]) {
        self.storeName = storeName
        self.restaurantType = restaurantType
        self.partnershipInfos = partnershipInfos
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - View Setup

    override func configureUI() {
        view.backgroundColor = .white

        storeNameLabel.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 16)
        storeNameLabel.textColor = .label

        typeIconImageView.contentMode = .scaleAspectFit
        typeIconImageView.snp.makeConstraints { $0.width.height.equalTo(18) }

        typeTextLabel.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 10)
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

        [storeNameLabel, typeStackView, infoListStackView].forEach {
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
        storeNameLabel.text = storeName

        switch restaurantType {
        case "RESTAURANT":
            typeIconImageView.image = EATSSUDesignAsset.Images.restaurantPin.image
            typeTextLabel.text = "음식점"
        case "CAFE":
            typeIconImageView.image = EATSSUDesignAsset.Images.cafePin.image
            typeTextLabel.text = "카페"
        case "PUB":
            typeIconImageView.image = EATSSUDesignAsset.Images.pubPin.image
            typeTextLabel.text = "주점"
        default:
            typeIconImageView.image = EATSSUDesignAsset.Images.restaurantPin.image
            typeTextLabel.text = restaurantType
        }

        for (index, info) in partnershipInfos.enumerated() {
            let isLast = index == partnershipInfos.count - 1
            let card = makeInfoCard(info: info, isLast: isLast)
            infoListStackView.addArrangedSubview(card)
        }
    }

    // MARK: - UI Helpers

    /// 제휴 content 갯수에 따라 유동적으로 Height 측정
    func calculatePreferredHeight() -> CGFloat {
        view.layoutIfNeeded()
        let contentHeight = infoListStackView.frame.maxY
        let bottomPadding: CGFloat = view.safeAreaInsets.bottom + 20
        
        return contentHeight + bottomPadding
    }
    
    /// 제휴 정보 카드 뷰 생성
    private func makeInfoCard(info: PartnershipInfoDTO, isLast: Bool) -> UIView {
        let labelText = info.collegeName ?? info.departmentName ?? "학과 정보 없음"
        
        let start = String(info.startDate.dropFirst(2))
        let end = String(info.endDate.dropFirst(2))

        let fullText = "\(labelText)  \(start) ~ \(end)"
        let attrText = NSMutableAttributedString(string: fullText)

        let collegeRange = (fullText as NSString).range(of: labelText)
        let dateRange = (fullText as NSString).range(of: "\(start) ~ \(end)")

        attrText.addAttributes([
            .font: EATSSUDesignFontFamily.Pretendard.medium.font(size: 14),
            .foregroundColor: UIColor.label
        ], range: collegeRange)

        attrText.addAttributes([
            .font: EATSSUDesignFontFamily.Pretendard.regular.font(size: 10),
            .foregroundColor: EATSSUDesignColors.Color.gray700,
            .baselineOffset: +2
        ], range: dateRange)

        let titleDateLabel = UILabel()
        titleDateLabel.attributedText = attrText

        let descriptionLabel = UILabel()
        descriptionLabel.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 12)
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

}
