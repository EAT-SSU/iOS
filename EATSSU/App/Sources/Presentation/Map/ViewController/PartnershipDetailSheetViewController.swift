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

    /// 시트에 표시할 업체 (지도 필터에 맞춰 제휴 항목이 걸러진 DTO)
    private let partnership: PartnershipDTO
    /// 찜 토글 대상 업체 (필터와 무관한 전체 제휴 항목). 업체 찜은 항상 모든 항목을 함께 다룬다
    private let likeTarget: PartnershipDTO
    /// 학과 미입력 시 찜 사용 불가 (기획). false면 하트를 숨긴다
    private let isLikeEnabled: Bool
    private let mapAppLauncher: MapAppLauncher

    // MARK: - UI Components

    private let storeNameLabel = UILabel()
    private let likeButton = UIButton(type: .custom)
    private let typeStackView = UIStackView()
    private let typeIconImageView = UIImageView()
    private let typeTextLabel = UILabel()
    private let infoListStackView = UIStackView()
    private let mapAppButtonBar = MapAppButtonBar()

    // MARK: - Init

    init(partnership: PartnershipDTO, likeTarget: PartnershipDTO? = nil, isLikeEnabled: Bool = true) {
        self.partnership = partnership
        self.likeTarget = likeTarget ?? partnership
        self.isLikeEnabled = isLikeEnabled
        self.mapAppLauncher = MapAppLauncher(destination: .init(
            name: partnership.storeName,
            latitude: partnership.latitude,
            longitude: partnership.longitude,
            kakaoMapUrl: partnership.kakaoMapUrl,
            naverMapUrl: partnership.naverMapUrl
        ))
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

        likeButton.tintColor = .gray700
        likeButton.isHidden = !isLikeEnabled
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        updateLikeButton()

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

        mapAppButtonBar.onKakaoMapTap = { [weak self] in self?.mapAppLauncher.openKakaoMap() }
        mapAppButtonBar.onNaverMapTap = { [weak self] in self?.mapAppLauncher.openNaverMap() }

        [storeNameLabel, likeButton, typeStackView, infoListStackView, mapAppButtonBar].forEach {
            view.addSubview($0)
        }
    }

    override func setLayout() {
        storeNameLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().inset(24)
            $0.trailing.lessThanOrEqualTo(likeButton.snp.leading).offset(-12)
        }

        likeButton.snp.makeConstraints {
            $0.centerY.equalTo(storeNameLabel)
            $0.trailing.equalToSuperview().inset(24)
            $0.width.height.equalTo(32)
        }

        typeStackView.snp.makeConstraints {
            $0.top.equalTo(storeNameLabel.snp.bottom).offset(4)
            $0.leading.equalTo(storeNameLabel)
        }

        infoListStackView.snp.makeConstraints {
            $0.top.equalTo(typeStackView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        // large로 확장 시에도 버튼 바가 시트 하단에 붙어있도록 bottom 고정
        mapAppButtonBar.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(infoListStackView.snp.bottom).offset(MapAppButtonBar.Layout.topSpacing)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(MapAppButtonBar.Layout.bottomInset)
        }
    }

    // MARK: - Data Config

    override func viewDidLoad() {
        super.viewDidLoad()
        configureData()
        // 찜 탭을 열기 전에 지도에서 시트를 열어도 하트가 서버 찜 상태를 반영하도록
        PartnershipLikeManager.shared.ensureLoaded { [weak self] in
            self?.updateLikeButton()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        logScreenView(screenID: FirebaseScreenID.Map.map2)
    }

    /// 시트가 화면에 붙어 실제 safe area가 확정되면 detent 높이 재계산
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        if #available(iOS 16.0, *) {
            sheetPresentationController?.invalidateDetents()
        }
    }

    /// 매장 정보와 제휴 내용을 화면에 반영
    private func configureData() {
        storeNameLabel.text = partnership.storeName

        typeIconImageView.image = MainMapViewController.partnershipIcon(
            for: partnership.restaurantType,
            isFestival: false
        )
        typeTextLabel.text = PartnershipFilter.allCases
            .first { $0.restaurantType == partnership.restaurantType }?
            .title ?? partnership.restaurantType

        for (index, info) in partnership.partnershipInfos.enumerated() {
            let isLast = index == partnership.partnershipInfos.count - 1
            let card = makeInfoCard(info: info, isLast: isLast)
            infoListStackView.addArrangedSubview(card)
        }
    }

    // MARK: - Like

    private var isLiked: Bool {
        PartnershipLikeManager.shared.isLiked(likeTarget)
    }

    private func updateLikeButton() {
        let image = isLiked ? EATSSUDesignAsset.Images.icLikeFilled.image : EATSSUDesignAsset.Images.icLikeLine.image
        likeButton.setImage(image, for: .normal)
        // VoiceOver: 이름은 '찜', 상태는 selected 트레이트로 전달
        likeButton.accessibilityLabel = TextLiteral.Like.title
        likeButton.accessibilityTraits = isLiked ? [.button, .selected] : [.button]
    }

    /// 하트 탭: 찜 토글. 삭제 시엔 '취소하기'로 되돌릴 수 있는 토스트를 띄운다
    @objc private func didTapLike() {
        likeButton.isEnabled = false
        // 찜 목록을 확보한 뒤 현재 상태를 판정한다 (받기 전엔 하트가 지도 응답 기준이라 어긋날 수 있음)
        PartnershipLikeManager.shared.ensureLoaded { [weak self] in
            guard let self else { return }
            self.setLiked(!self.isLiked)
        }
    }

    private func setLiked(_ liked: Bool) {
        likeButton.isEnabled = false
        PartnershipLikeManager.shared.setLiked(liked, store: likeTarget) { [weak self] result in
            guard let self else { return }
            self.likeButton.isEnabled = true
            self.updateLikeButton()

            switch result {
            case .success:
                if liked {
                    self.showToast(message: TextLiteral.Like.addedToast, type: .success)
                } else {
                    // 취소하기는 한 번만 동작 (토글 API라 두 번 누르면 원복이 뒤집힘)
                    var didUndo = false
                    self.showToast(
                        message: TextLiteral.Like.removedToast,
                        type: .success,
                        actionTitle: TextLiteral.Like.undo
                    ) { [weak self] in
                        guard !didUndo else { return }
                        didUndo = true
                        self?.setLiked(true)
                    }
                }
            case .failure:
                self.showToast(message: TextLiteral.Like.updateFailed, type: .danger)
            }
        }
    }

    // MARK: - UI Helpers

    /// 제휴 content 갯수에 따라 유동적으로 Height 측정
    /// 버튼 바는 시트 하단에 고정이므로 리스트 높이 기준으로 계산
    func calculatePreferredHeight() -> CGFloat {
        view.layoutIfNeeded()
        return infoListStackView.frame.maxY + MapAppButtonBar.Layout.totalArea + view.safeAreaInsets.bottom
    }
    
    /// 제휴 정보 카드 뷰 생성
    private func makeInfoCard(info: PartnershipInfoDTO, isLast: Bool) -> UIView {
        let labelText = TextLiteral.Academic.college(info.collegeName)
            ?? TextLiteral.Academic.department(info.departmentName)
            ?? TextLiteral.Map.noDepartmentInfo
        
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
            .foregroundColor: EATSSUDesignColors.Color.gray500, // 디자인 #9D9D9D
            .baselineOffset: +1
        ], range: dateRange)

        let titleDateLabel = UILabel()
        titleDateLabel.attributedText = attrText

        let descriptionLabel = UILabel()
        descriptionLabel.textColor = EATSSUDesignColors.Color.gray600 // 디자인 #565656
        descriptionLabel.numberOfLines = 0
        // 여러 줄 설명은 줄간격을 벌려 가독성을 확보한다 (피그마 수치 확정 시 조정)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        descriptionLabel.attributedText = NSAttributedString(
            string: info.description,
            attributes: [.paragraphStyle: paragraphStyle, .font: UIFont.body3]
        )

        let contentStack = UIStackView(arrangedSubviews: [titleDateLabel, descriptionLabel])
        contentStack.axis = .vertical
        // 설명 내부 줄간격(6)보다 확실히 넓혀 단과대 제목 블록이 구분되게 한다 (Frame 43540 기준 + 여백 보강)
        contentStack.spacing = 12

        let separator = UIView()
        separator.backgroundColor = EATSSUDesignColors.Color.gray300
        separator.isHidden = isLast
        separator.snp.makeConstraints {
            $0.height.equalTo(1)
        }

        let container = UIStackView(arrangedSubviews: [contentStack, separator])
        container.axis = .vertical
        container.spacing = 12

        let paddedContainer = UIView()
        paddedContainer.addSubview(container)
        container.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0))
        }

        return paddedContainer
    }
}
