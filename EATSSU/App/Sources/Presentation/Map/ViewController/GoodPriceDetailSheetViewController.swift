//
//  GoodPriceDetailSheetViewController.swift
//  EATSSU
//
//  Created by 황상환 on 8/23/26.
//

import UIKit

import Kingfisher
import SnapKit

import EATSSUDesign

/// 착한가격업소 마커 선택 시 업소명/업종/주소/대표메뉴/가격/대표이미지를 보여주는 바텀시트
/// 하단에 카카오맵/네이버지도 이동 버튼 제공 (서버 URL이 없어 카카오 로컬 검색 → 폴백 경로로 연결)
final class GoodPriceDetailSheetViewController: BaseViewController {

    // MARK: - Constants

    private enum Layout {
        static let horizontalInset: CGFloat = 24
        static let imageSize: CGFloat = 120
    }

    // MARK: - Properties

    private let store: GoodPriceStoreDTO
    private let mapAppLauncher: MapAppLauncher

    // MARK: - UI Components

    private let storeNameLabel = UILabel()
    private let categoryStackView = UIStackView()
    private let categoryIconImageView = UIImageView()
    private let categoryTextLabel = UILabel()
    private let addressLabel = UILabel()
    private let menuLabel = UILabel()
    private let textStackView = UIStackView()
    private let storeImageView = UIImageView()
    private let mapAppButtonBar = MapAppButtonBar()

    // MARK: - Init

    init(store: GoodPriceStoreDTO) {
        self.store = store
        // 착한가격업소는 서버가 지도 URL을 주지 않으므로 상호명 + 좌표 기반 검색으로 연결
        self.mapAppLauncher = MapAppLauncher(destination: .init(
            name: store.storeName,
            latitude: store.latitude,
            longitude: store.longitude
        ))
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Setup

    override func configureUI() {
        view.backgroundColor = .white

        storeNameLabel.font = .header2
        storeNameLabel.textColor = .label
        storeNameLabel.numberOfLines = 2

        categoryIconImageView.contentMode = .scaleAspectFit
        categoryIconImageView.snp.makeConstraints { $0.width.height.equalTo(18) }

        categoryTextLabel.font = .body2
        categoryTextLabel.textColor = .gray

        categoryStackView.axis = .horizontal
        categoryStackView.alignment = .center
        categoryStackView.spacing = 4
        categoryStackView.addArrangedSubview(categoryIconImageView)
        categoryStackView.addArrangedSubview(categoryTextLabel)

        addressLabel.font = .subtitle2
        addressLabel.textColor = .label
        addressLabel.numberOfLines = 0

        menuLabel.font = .body3
        menuLabel.textColor = .gray700
        menuLabel.numberOfLines = 0

        textStackView.axis = .vertical
        textStackView.alignment = .leading
        textStackView.spacing = 6
        textStackView.addArrangedSubview(storeNameLabel)
        textStackView.addArrangedSubview(categoryStackView)
        textStackView.setCustomSpacing(16, after: categoryStackView)
        textStackView.addArrangedSubview(addressLabel)
        textStackView.addArrangedSubview(menuLabel)

        storeImageView.contentMode = .scaleAspectFill
        storeImageView.clipsToBounds = true
        storeImageView.layer.cornerRadius = 8
        storeImageView.backgroundColor = .gray300

        mapAppButtonBar.onKakaoMapTap = { [weak self] in self?.mapAppLauncher.openKakaoMap() }
        mapAppButtonBar.onNaverMapTap = { [weak self] in self?.mapAppLauncher.openNaverMap() }

        view.addSubviews(textStackView, storeImageView, mapAppButtonBar)
    }

    override func setLayout() {
        storeImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.width.height.equalTo(Layout.imageSize)
        }

        textStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().inset(Layout.horizontalInset)
            $0.trailing.equalTo(storeImageView.snp.leading).offset(-16)
        }

        // large로 확장 시에도 버튼 바가 시트 하단에 붙어있도록 bottom 고정
        mapAppButtonBar.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(textStackView.snp.bottom).offset(MapAppButtonBar.Layout.topSpacing)
            $0.top.greaterThanOrEqualTo(storeImageView.snp.bottom).offset(MapAppButtonBar.Layout.topSpacing)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(MapAppButtonBar.Layout.bottomInset)
        }
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBasicInfo()
        fetchDetail()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logScreenView(screenID: FirebaseScreenID.Map.map4)
    }

    /// 시트가 화면에 붙어 실제 safe area가 확정되면 detent 높이 재계산
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        if #available(iOS 16.0, *) {
            sheetPresentationController?.invalidateDetents()
        }
    }

    // MARK: - Data

    /// 목록 API에 있는 정보(업소명/업종)는 상세 응답 전에 먼저 표시
    private func configureBasicInfo() {
        storeNameLabel.text = store.storeName
        categoryIconImageView.image = MainMapViewController.goodPriceIcon(for: store.category)
        categoryTextLabel.text = GoodPriceCategory(serverValue: store.category)?.title ?? store.category
    }

    private func fetchDetail() {
        NetworkService.shared.request(
            GoodPriceStoreRouter.getStoreDetail(id: store.id),
            responseType: GoodPriceStoreDetailDTO.self,
            useAuth: false
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let detail):
                self.applyDetail(detail)
            case .failure(let error):
                print("착한가격업소 상세 조회 실패: \(error.localizedDescription)")
                // 시트가 지도 위에 떠 있으므로 토스트는 시트 자신의 view에 띄운다
                self.showToast(message: TextLiteral.Map.storeLoadFailed, type: .danger)
            }
        }
    }

    private func applyDetail(_ detail: GoodPriceStoreDetailDTO) {
        storeNameLabel.text = detail.storeName
        addressLabel.text = detail.roadAddress
        addressLabel.isHidden = (detail.roadAddress ?? "").isEmpty

        menuLabel.text = Self.menuText(menu: detail.mainMenu, price: detail.price)
        menuLabel.isHidden = menuLabel.text == nil

        if let urlString = detail.imageUrl, let url = URL(string: urlString) {
            storeImageView.kf.setImage(with: url)
        }

        if #available(iOS 16.0, *) {
            sheetPresentationController?.animateChanges {
                self.sheetPresentationController?.invalidateDetents()
            }
        }
    }

    /// "메뉴명 가격원" 형태로 조합. 둘 다 없으면 nil
    private static func menuText(menu: String?, price: Int?) -> String? {
        let menuPart = menu?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let pricePart: String
        if let price {
            pricePart = TextLiteral.Map.priceWon(price.formattedWithCommas)
        } else {
            pricePart = ""
        }

        let joined = [menuPart, pricePart].filter { !$0.isEmpty }.joined(separator: " ")
        return joined.isEmpty ? nil : joined
    }

    // MARK: - Height

    /// 텍스트/이미지 중 더 큰 쪽 기준으로 시트 높이 계산
    /// 버튼 바는 시트 하단에 고정이므로 컨텐츠 높이 기준으로 계산
    func calculatePreferredHeight() -> CGFloat {
        view.layoutIfNeeded()
        let contentBottom = max(textStackView.frame.maxY, storeImageView.frame.maxY)
        return contentBottom + MapAppButtonBar.Layout.totalArea + view.safeAreaInsets.bottom
    }
}
