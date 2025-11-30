//
//  ReviewTableCell.swift
//  EatSSU-iOS
//
//  Created by 한금준 on 20/11/25.
//

import UIKit
import SnapKit

import EATSSUDesign

// MARK: - ReviewTableCell

/// 개별 리뷰를 표시하는 테이블뷰 셀
final class ReviewTableCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "ReviewTableCell"
    
    var handler: (() -> Void)?
    var reviewId: Int = 0
    var menuName: String = ""
    private var tags: [(name: String, isLiked: Bool)] = []

    private var tagCollectionViewHeightConstraint: Constraint?
    
    // MARK: - UI Components - Profile Section
    
    private let userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.profile.image
        return imageView
    }()
    
    private var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "hellosoongsil1234"
        label.font = .caption1
        label.textColor = .black
        return label
    }()
    
    lazy var totalRateView = RateNumberView()
    
    lazy var nameMenuStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [userNameLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8.adjusted
        stackView.alignment = .center
        return stackView
    }()
    
    lazy var rateStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [totalRateView])
        stackView.axis = .horizontal
        stackView.spacing = 8.adjusted
        stackView.alignment = .center
        return stackView
    }()
    
    lazy var infoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameMenuStackView, rateStackView])
        stackView.axis = .vertical
        stackView.spacing = 4.adjusted
        stackView.alignment = .leading
        return stackView
    }()
    
    lazy var profileStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [userProfileImageView, infoStackView])
        stackView.axis = .horizontal
        stackView.spacing = 8.adjusted
        stackView.alignment = .center
        return stackView
    }()
    
    // MARK: - UI Components - Right Section
    
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "2023.03.03"
        label.font = .caption3
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray600.color
        return label
    }()
    
    private var sideButton: BaseButton = {
        let button = BaseButton()
        button.setTitleColor(EATSSUDesignAsset.Color.GrayScale.gray400.color, for: .normal)
        button.titleLabel?.font = .caption2
        button.configuration?.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 15)
        return button
    }()
    
    lazy var dateReportStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [sideButton, dateLabel])
        stackView.axis = .vertical
        stackView.spacing = 11.adjusted
        stackView.alignment = .trailing
        return stackView
    }()
    
    // MARK: - UI Components - Content Section
    
    /// 메뉴 태그 컬렉션뷰
    private lazy var tagCollectionView: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: 100, height: 26)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.register(
            ReviewTagCollectionViewCell.self,
            forCellWithReuseIdentifier: ReviewTagCollectionViewCell.identifier
        )
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    var reviewTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = UIColor.black
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .systemBackground
        textView.font = .body1
        textView.text = "여기 계란국 맛집임... 김치볶음밥에 계란후라이 없어서 아쉽 다음에 또 먹어야지"
        return textView
    }()
    
    var foodImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            tagCollectionView,
            reviewTextView,
            foodImageView
        ])
        stackView.axis = .vertical
        stackView.spacing = 8.adjusted
        stackView.alignment = .leading
        return stackView
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        tags = []
        tagCollectionView.reloadData()
        sideButton.setTitle("", for: .normal)
        sideButton.setImage(UIImage(), for: .normal)
        foodImageView.image = UIImage()
        foodImageView.isHidden = true
        reviewTextView.text = ""
        dateLabel.text = ""
        userNameLabel.text = ""
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // layoutSubviews에서 높이 업데이트 로직 제거 (dataBind로 이동)
    }
    
    // MARK: - UI Configuration
    
    private func setupUI() {
        contentView.addSubview(profileStackView)
        contentView.addSubview(dateReportStackView)
        contentView.addSubview(contentStackView)
        
        contentStackView.setCustomSpacing(8, after: reviewTextView)
    }
    
    func setLayout() {
        userProfileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
        
        profileStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(50)
        }
        
        dateReportStackView.snp.makeConstraints { make in
            make.centerY.equalTo(profileStackView)
            make.trailing.equalToSuperview().inset(16)
        }
        
        sideButton.snp.makeConstraints {
            $0.height.equalTo(12.adjusted)
        }
        
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(profileStackView.snp.bottom)
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        // 태그 컬렉션뷰
        tagCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            // 높이 제약을 저장하고 기본 높이를 줍니다.
            tagCollectionViewHeightConstraint = make.height.equalTo(26).constraint
        }
        
        foodImageView.snp.makeConstraints { make in
            make.top.equalTo(reviewTextView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(foodImageView.snp.width).multipliedBy(0.75)
        }
    }
    
    // MARK: - Actions
    
    @objc
    func touchedSideButtonEvent() {
        handler?()
    }
    
    // MARK: - Public Methods
    
    func dataBind(response: ReviewListItem) {
        
        // 💡 1. 텍스트뷰의 너비가 계산되도록 레이아웃 업데이트 (시작)
        self.layoutIfNeeded()
        
        menuName = response.menu?.map { $0.name }.joined(separator: " + ") ?? ""
        
        userNameLabel.text = response.writerNickname
        totalRateView.setRating(Int(response.rating))
        dateLabel.text = response.writtenAt
        reviewTextView.text = response.content ?? ""
        reviewId = response.reviewId
        
        // 💡 2. 텍스트뷰 높이를 내용물에 맞게 계산하여 프레임 업데이트
        let fixedWidth = reviewTextView.frame.size.width
        let newSize = reviewTextView.sizeThatFits(CGSize(width: fixedWidth, height: .greatestFiniteMagnitude))
        reviewTextView.frame.size.height = newSize.height
        
        if let firstImageUrl = response.imageUrls?.first(where: { !$0.isEmpty }) {
            foodImageView.isHidden = false
            foodImageView.kfSetImage(url: firstImageUrl)
        } else {
            foodImageView.isHidden = true
        }
        
        sideButton.setImage(EATSSUDesignAsset.Images.icMenu.image, for: .normal)
        sideButton.addTarget(self, action: #selector(touchedSideButtonEvent), for: .touchUpInside)
        
        if let menuTags = response.menu, !menuTags.isEmpty {
            tags = menuTags.map { ($0.name, $0.isLike) }
        } else {
            tags = []
        }
        
        tagCollectionView.isHidden = tags.isEmpty
        tagCollectionView.reloadData()

        tagCollectionView.layoutIfNeeded()
        
        // 🚀 3. 컬렉션 뷰 높이 업데이트 및 셀 레이아웃 강제 업데이트 (비동기)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let contentHeight = self.tagCollectionView.collectionViewLayout.collectionViewContentSize.height
            
            if contentHeight > 0 {
                self.tagCollectionViewHeightConstraint?.update(offset: contentHeight)
                
                // 텍스트뷰와 컬렉션뷰의 높이 변경을 스택뷰와 셀이 반영하도록 강제합니다.
                self.contentView.layoutIfNeeded()
            }
        }
    }
    
    func myPageDataBind(response: MyReviewListItem, nickname: String) {
        // 💡 1. 텍스트뷰의 너비가 계산되도록 레이아웃 업데이트 (시작)
        self.layoutIfNeeded()
        
        userNameLabel.text = "\(nickname)"
        totalRateView.setRating(Int(response.rating ?? 0))
        dateLabel.text = response.writtenAt
        
        reviewTextView.text = response.content
        
        // 💡 2. 텍스트뷰 높이를 내용물에 맞게 계산하여 프레임 업데이트
        let fixedWidth = reviewTextView.frame.size.width
        let newSize = reviewTextView.sizeThatFits(CGSize(width: fixedWidth, height: .greatestFiniteMagnitude))
        reviewTextView.frame.size.height = newSize.height
        
        if let imageUrls = response.imageUrls,
           let firstImageUrl = imageUrls.first(where: { !$0.isEmpty }) {
            
            foodImageView.isHidden = false
            foodImageView.kfSetImage(url: firstImageUrl)
            
        } else {
            foodImageView.isHidden = true
        }
        
        sideButton.addTarget(self, action: #selector(touchedSideButtonEvent), for: .touchUpInside)
        sideButton.setImage(EATSSUDesignAsset.Images.icMenu.image, for: .normal)
        sideButton.setTitle("", for: .normal)
        
        reviewId = response.reviewId
        tags = []
        tagCollectionView.isHidden = true
        
        // 🚀 3. 셀 레이아웃 강제 업데이트
        self.contentView.layoutIfNeeded()
    }
}

// MARK: - UICollectionViewDataSource

extension ReviewTableCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ReviewTagCollectionViewCell.identifier,
            for: indexPath
        ) as? ReviewTagCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let tag = tags[indexPath.item]
        cell.configure(tagName: tag.name, isLiked: tag.isLiked)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ReviewTableCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let tag = tags[indexPath.item]
        let maxWidth = collectionView.bounds.width - 32
        
        return ReviewTagCollectionViewCell.estimatedSize(
            for: tag.name,
            isLiked: tag.isLiked,
            maxWidth: maxWidth
        )
    }
}

// MARK: - LeftAlignedCollectionViewFlowLayout

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        
        let modifiedAttributes = attributes.compactMap { layoutAttribute -> UICollectionViewLayoutAttributes? in
            guard layoutAttribute.representedElementCategory == .cell else {
                return layoutAttribute
            }
            
            let copiedAttribute = layoutAttribute.copy() as! UICollectionViewLayoutAttributes
            
            if copiedAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            
            copiedAttribute.frame.origin.x = leftMargin
            
            leftMargin = copiedAttribute.frame.maxX + minimumInteritemSpacing
            maxY = max(maxY, copiedAttribute.frame.maxY)
            
            return copiedAttribute
        }
        
        return modifiedAttributes
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return super.collectionViewContentSize
        }
        
        let superSize = super.collectionViewContentSize
        let minHeight: CGFloat = 26 + sectionInset.top + sectionInset.bottom
        let actualHeight = max(superSize.height, minHeight)
        
        return CGSize(width: collectionView.bounds.width, height: actualHeight)
    }
}
