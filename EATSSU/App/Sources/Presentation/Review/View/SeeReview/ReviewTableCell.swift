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
    
    /// 더보기 버튼 탭 핸들러
    var handler: (() -> Void)?
    
    /// 리뷰 ID
    var reviewId: Int = 0
    
    /// 메뉴 이름
    var menuName: String = ""
    
    /// 메뉴 태그 데이터
    private var tags: [(name: String, isLiked: Bool)] = []
    
    // MARK: - UI Components - Profile Section
    
    /// 사용자 프로필 이미지
    private let userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.profile.image
        return imageView
    }()
    
    /// 사용자 닉네임 레이블
    private var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "hellosoongsil1234"
        label.font = .caption1
        label.textColor = .black
        return label
    }()
    
    /// 별점 표시 뷰
    lazy var totalRateView = RateNumberView()
    
    /// 닉네임과 메뉴를 담는 스택뷰
    lazy var nameMenuStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [userNameLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8.adjusted
        stackView.alignment = .center
        return stackView
    }()
    
    /// 별점 스택뷰
    lazy var rateStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [totalRateView])
        stackView.axis = .horizontal
        stackView.spacing = 8.adjusted
        stackView.alignment = .center
        return stackView
    }()
    
    /// 사용자 정보(닉네임, 별점) 스택뷰
    lazy var infoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameMenuStackView, rateStackView])
        stackView.axis = .vertical
        stackView.spacing = 4.adjusted
        stackView.alignment = .leading
        return stackView
    }()
    
    /// 프로필 전체 스택뷰
    lazy var profileStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [userProfileImageView, infoStackView])
        stackView.axis = .horizontal
        stackView.spacing = 8.adjusted
        stackView.alignment = .center
        return stackView
    }()
    
    // MARK: - UI Components - Right Section
    
    /// 작성 날짜 레이블
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "2023.03.03"
        label.font = .caption3
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray600.color
        return label
    }()
    
    /// 더보기 버튼 (수정/삭제/신고)
    private var sideButton: BaseButton = {
        let button = BaseButton()
        button.setTitleColor(EATSSUDesignAsset.Color.GrayScale.gray400.color, for: .normal)
        button.titleLabel?.font = .caption2
        button.configuration?.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 15)
        return button
    }()
    
    /// 날짜와 더보기 버튼 스택뷰
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
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
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
        return cv
    }()
    
    /// 리뷰 내용 텍스트뷰
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
    
    /// 음식 이미지뷰
    var foodImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    /// 콘텐츠(태그, 텍스트, 이미지) 스택뷰
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
        
        // 재사용 시 데이터 초기화
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
    
    // MARK: - UI Configuration
    
    /// UI 컴포넌트 추가
    private func setupUI() {
        contentView.addSubview(profileStackView)
        contentView.addSubview(dateReportStackView)
        contentView.addSubview(contentStackView)
        
        // 리뷰 텍스트 뒤에 추가 간격 설정
        contentStackView.setCustomSpacing(8, after: reviewTextView)
    }
    
    /// 레이아웃 제약조건 설정
    func setLayout() {
        // 프로필 이미지
        userProfileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
        
        // 프로필 섹션
        profileStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(50)
        }
        
        // 날짜/더보기 버튼 섹션
        dateReportStackView.snp.makeConstraints { make in
            make.centerY.equalTo(profileStackView)
            make.trailing.equalToSuperview().inset(16)
        }
        
        sideButton.snp.makeConstraints {
            $0.height.equalTo(12.adjusted)
        }
        
        // 콘텐츠 섹션
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(profileStackView.snp.bottom)
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-15)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        // 태그 컬렉션뷰
        tagCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.greaterThanOrEqualTo(30)
        }
        
        // 음식 이미지
        foodImageView.snp.makeConstraints { make in
            make.top.equalTo(reviewTextView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(foodImageView.snp.width).multipliedBy(0.75)
        }
    }
    
    // MARK: - Actions
    
    /// 더보기 버튼 탭 이벤트
    @objc
    func touchedSideButtonEvent() {
        handler?()
    }
    
    // MARK: - Public Methods
    
    /// 리뷰 데이터로 셀 구성
    /// - Parameter response: 리뷰 리스트 아이템
    func dataBind(response: ReviewListItem) {
        // 메뉴 이름 설정
        menuName = response.menu?.map { $0.name }.joined(separator: " + ") ?? ""
        
        // 기본 정보 설정
        userNameLabel.text = response.writerNickname
        totalRateView.setRating(Int(response.rating))
        dateLabel.text = response.writtenAt
        reviewTextView.text = response.content ?? ""
        reviewId = response.reviewId
        
        // 이미지 설정
        if let firstImageUrl = response.imageUrls?.first(where: { !$0.isEmpty }) {
            foodImageView.isHidden = false
            foodImageView.kfSetImage(url: firstImageUrl)
        } else {
            foodImageView.isHidden = true
        }
        
        // 더보기 버튼 설정
        sideButton.setImage(EATSSUDesignAsset.Images.icMenu.image, for: .normal)
        sideButton.addTarget(self, action: #selector(touchedSideButtonEvent), for: .touchUpInside)
        
        // 태그 설정
        if let menuTags = response.menu, !menuTags.isEmpty {
            tags = menuTags.map { ($0.name, $0.isLike) }
        } else {
            tags = []
        }
        tagCollectionView.reloadData()
        tagCollectionView.isHidden = tags.isEmpty
    }
    
    /// 마이페이지용 리뷰 데이터 바인딩
    /// - Parameters:
    ///   - response: MyReviewListItem DTO
    ///   - nickname: 사용자 닉네임
    func myPageDataBind(response: MyReviewListItem, nickname: String) { // 인자 타입 변경 (MyDataList -> MyReviewListItem)
        userNameLabel.text = "\(nickname)"
        totalRateView.setRating(Int(response.rating ?? 0))
        dateLabel.text = response.writtenAt
        
        reviewTextView.text = response.content
        
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
    }
}

// MARK: - UICollectionViewDataSource

extension ReviewTableCell: UICollectionViewDataSource {
    
    /// 컬렉션뷰 아이템 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    /// 컬렉션뷰 셀 구성
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
