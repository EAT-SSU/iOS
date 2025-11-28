//
//  ReviewTableCell.swift
//  EatSSU-iOS
//
//  Updated to use ReviewListItem instead of MenuDataList
//

import UIKit
import SnapKit
import EATSSUDesign

final class ReviewTableCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "ReviewTableCell"
    var handler: (() -> Void)?
    var reviewId: Int = .init()
    var menuName: String = .init()
    
    // MARK: - UI Components
    
    lazy var totalRateView = RateNumberView()
    
    // 태그 표시용 컬렉션 뷰
    private lazy var tagCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.register(ReviewTagCollectionViewCell.self, forCellWithReuseIdentifier: ReviewTagCollectionViewCell.identifier)
        cv.dataSource = self
        return cv
    }()
    
    private var tags: [(name: String, isLiked: Bool)] = []
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [tagCollectionView, reviewTextView, foodImageView])
        stackView.axis = .vertical
        stackView.spacing = 8.adjusted
        stackView.alignment = .leading
        return stackView
    }()
    
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "2023.03.03"
        label.font = .caption3
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray600.color
        return label
    }()
    
    private var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "hellosoongsil1234"
        label.font = .caption1
        label.textColor = .black
        return label
    }()
    
    private let userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.profile.image
        return imageView
    }()
    
    private var sideButton: BaseButton = {
        let button = BaseButton()
        button.setTitleColor(EATSSUDesignAsset.Color.GrayScale.gray400.color, for: .normal)
        button.titleLabel?.font = .caption2
        button.configuration?.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 15)
        return button
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
        return imageView
    }()
    
    /// 별점
    lazy var rateStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [totalRateView])
        stackView.axis = .horizontal
        stackView.spacing = 8.adjusted
        stackView.alignment = .center
        return stackView
    }()
    
    /// 이름 + 메뉴
    lazy var nameMenuStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [userNameLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8.adjusted
        stackView.alignment = .center
        return stackView
    }()
    
    /// 이름 + 메뉴 + 별점
    lazy var infoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameMenuStackView, rateStackView])
        stackView.axis = .vertical
        stackView.spacing = 4.adjusted
        stackView.alignment = .leading
        return stackView
    }()
    
    /// 프로필 + 이름 + 메뉴 + 별점
    lazy var profileStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [userProfileImageView, infoStackView])
        stackView.axis = .horizontal
        stackView.spacing = 8.adjusted
        stackView.alignment = .center
        return stackView
    }()
    
    lazy var dateReportStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [sideButton, dateLabel])
        stackView.axis = .vertical
        stackView.spacing = 11.adjusted
        stackView.alignment = .trailing
        return stackView
    }()
    
    // MARK: - Functions
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(profileStackView)
        contentView.addSubview(dateReportStackView)
        contentView.addSubview(contentStackView)
        contentStackView.setCustomSpacing(8, after: reviewTextView)
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    func setLayout() {
        userProfileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
        
        profileStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(50)
        }
        
        dateReportStackView.snp.makeConstraints { make in
            make.centerY.equalTo(profileStackView)
            make.trailing.equalToSuperview().inset(16)
        }
        
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(profileStackView.snp.bottom)
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-15)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        foodImageView.snp.makeConstraints { make in
//            make.height.width.equalTo(358)
            make.top.equalTo(reviewTextView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(foodImageView.snp.width).multipliedBy(0.75)
        }
        
        sideButton.snp.makeConstraints {
            $0.height.equalTo(12.adjusted)
        }
        
        tagCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.greaterThanOrEqualTo(30)
        }
    }
    
    @objc
    func touchedSideButtonEvent() {
        handler?()
    }
}

// MARK: - CollectionView DataSource
extension ReviewTableCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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

// MARK: - Data Bind

extension ReviewTableCell {
    // ✨ V2 API: ReviewListItem 직접 바인딩
    func dataBind(response: ReviewListItem) {
        // 메뉴명 설정 (여러 메뉴인 경우 " + "로 연결)
        menuName = response.menu?.map { $0.name }.joined(separator: " + ") ?? ""
        
        // 기본 정보
        userNameLabel.text = response.writerNickname
        totalRateView.setRating(Int(response.rating))
        dateLabel.text = response.writtenAt
        reviewTextView.text = response.content ?? ""
        reviewId = response.reviewId
        
        // 이미지 처리
        if let firstImageUrl = response.imageUrls?.first(where: { !$0.isEmpty }) {
            foodImageView.isHidden = false
            foodImageView.kfSetImage(url: firstImageUrl)
        } else {
            foodImageView.isHidden = true
        }
        
        // 버튼 설정
        sideButton.setImage(EATSSUDesignAsset.Images.icMenu.image, for: .normal)
        sideButton.addTarget(self, action: #selector(touchedSideButtonEvent), for: .touchUpInside)
        
        // ✨ 태그 처리 (V2 API에서는 menu가 태그 역할)
        if let menuTags = response.menu, !menuTags.isEmpty {
            tags = menuTags.map { ($0.name, $0.isLike) }
        } else {
            tags = []
        }
        tagCollectionView.reloadData()
        
        // 태그가 없으면 컬렉션뷰 숨기기
        tagCollectionView.isHidden = tags.isEmpty
    }
    
    // 마이페이지용 바인딩 (기존 호환성 유지)
    func myPageDataBind(response: MyDataList, nickname: String) {
        userNameLabel.text = "\(nickname)"
        totalRateView.setRating(response.mainRating)
        dateLabel.text = response.writeDate
        reviewTextView.text = response.content
        
        // 이미지 처리
        if response.imgURLList.count != 0 {
            if response.imgURLList[0] != "" {
                foodImageView.isHidden = false
                foodImageView.kfSetImage(url: response.imgURLList[0])
            }
        } else {
            foodImageView.isHidden = true
        }
        
        // 버튼 설정
        sideButton.addTarget(self, action: #selector(touchedSideButtonEvent), for: .touchUpInside)
        sideButton.setImage(EATSSUDesignAsset.Images.icMenu.image, for: .normal)
        sideButton.setTitle("", for: .normal)
        reviewId = response.reviewID
        
        // 마이페이지에서는 태그 숨김
        tags = []
        tagCollectionView.isHidden = true
    }
}
