//
//  MenuFavoriteCell.swift
//  EATSSU
//
//  Created by 황상환 on 10/6/26.
//

import UIKit

import SnapKit

import EATSSUDesign

/// 메뉴 찜 한 줄: 메뉴명 · 식당명 · 하트
final class MenuFavoriteCell: UITableViewCell {

    // MARK: - Types

    enum Style {
        /// 내가 찜한 메뉴 목록. 디자인: 좌우 26, 행 높이 36, Medium 14
        case favorite
        /// 검색 결과. 디자인: 좌우 24, 행 높이 34, Regular 14 + 검색어 Bold 14
        case search(keyword: String)
    }

    // MARK: - Constants

    static let identifier = "MenuFavoriteCell"

    private enum Layout {
        static let favoriteInset: CGFloat = 26
        static let searchInset: CGFloat = 24
        // 14pt 한 줄(약 17)에 위아래 여백을 더해 디자인 행 높이(36 / 34)를 맞춘다
        static let favoriteVerticalInset: CGFloat = 9.5
        static let searchVerticalInset: CGFloat = 8.5
        /// 하트 에셋은 24pt 캔버스에 18pt 하트가 그려져 있다 (디자인 하트 18×16)
        static let heartSize: CGFloat = 24
        /// 하트 터치 영역
        static let heartTouchSize: CGFloat = 44
        static let textHeartSpacing: CGFloat = 12
    }

    // MARK: - Properties

    var onTapHeart: (() -> Void)?

    // MARK: - UI Components

    private let nameLabel = UILabel()
    private let restaurantLabel = UILabel()
    private let textStackView = UIStackView()
    private let heartButton = UIButton(type: .custom)

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
        setLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onTapHeart = nil
    }

    // MARK: - View Setup

    private func configureUI() {
        selectionStyle = .none
        backgroundColor = .white

        nameLabel.textColor = .black
        nameLabel.numberOfLines = 1
        nameLabel.lineBreakMode = .byTruncatingTail

        // 같은 메뉴명이 식당별로 따로 내려와 구분용으로 표시 (디자인 확정 전 임시)
        restaurantLabel.font = .caption2
        restaurantLabel.textColor = .gray500

        textStackView.axis = .vertical
        textStackView.alignment = .leading
        textStackView.spacing = 2
        textStackView.addArrangedSubview(nameLabel)
        textStackView.addArrangedSubview(restaurantLabel)

        heartButton.tintColor = .gray700
        heartButton.addTarget(self, action: #selector(didTapHeart), for: .touchUpInside)

        contentView.addSubviews(textStackView, heartButton)
    }

    private func setLayout() {
        applyLayout(inset: Layout.favoriteInset, verticalInset: Layout.favoriteVerticalInset)
    }

    private func applyLayout(inset: CGFloat, verticalInset: CGFloat) {
        // 24pt 아이콘이 디자인 위치에 오도록 44pt 터치 영역의 중심을 아이콘 중심에 맞춘다
        let heartCenterTrailing = inset + Layout.heartSize / 2
        heartButton.snp.remakeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalTo(contentView.snp.trailing).offset(-heartCenterTrailing)
            $0.width.height.equalTo(Layout.heartTouchSize)
        }
        textStackView.snp.remakeConstraints {
            $0.leading.equalToSuperview().inset(inset)
            $0.trailing.lessThanOrEqualToSuperview().inset(inset + Layout.heartSize + Layout.textHeartSpacing)
            $0.top.bottom.equalToSuperview().inset(verticalInset)
        }
    }

    // MARK: - Configuration

    func configure(name: String, restaurant: String?, isFavorite: Bool, style: Style) {
        switch style {
        case .favorite:
            // 검색 결과로 쓰였던 셀이면 attributedText 속성이 남지 않게 초기화한다
            nameLabel.attributedText = nil
            nameLabel.font = .body2
            nameLabel.textColor = .black
            nameLabel.text = name
            applyLayout(inset: Layout.favoriteInset, verticalInset: Layout.favoriteVerticalInset)
        case .search(let keyword):
            nameLabel.attributedText = Self.highlighted(name, keyword: keyword)
            applyLayout(inset: Layout.searchInset, verticalInset: Layout.searchVerticalInset)
        }

        restaurantLabel.text = restaurant
        restaurantLabel.isHidden = (restaurant ?? "").isEmpty

        let image = isFavorite ? EATSSUDesignAsset.Images.icLikeFilled.image : EATSSUDesignAsset.Images.icLikeLine.image
        heartButton.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        heartButton.accessibilityLabel = name
        heartButton.accessibilityTraits = isFavorite ? [.button, .selected] : .button
    }

    /// 검색어와 일치하는 부분만 Bold 14, 나머지는 Regular 14 (대소문자 무시)
    static func highlighted(_ name: String, keyword: String) -> NSAttributedString {
        let attributed = NSMutableAttributedString(
            string: name,
            attributes: [.font: UIFont.body3, .foregroundColor: UIColor.black]
        )
        let keyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else { return attributed }

        var searchRange = name.startIndex..<name.endIndex
        while let range = name.range(of: keyword, options: .caseInsensitive, range: searchRange) {
            attributed.addAttribute(.font, value: EATSSUDesignFontFamily.Pretendard.bold.font(size: 14), range: NSRange(range, in: name))
            searchRange = range.upperBound..<name.endIndex
        }
        return attributed
    }

    // MARK: - Actions

    @objc private func didTapHeart() {
        onTapHeart?()
    }
}
