//
//  ReviewTableCell.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/03/23.
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
//    lazy var tasteRateView = RateNumberView()
//    lazy var quantityRateView = RateNumberView()

//    private let tasteLabel: UILabel = {
//        let label = UILabel()
//        label.text = "맛"
//        label.font = .body3
//        label.textColor = .black
//        return label
//    }()

//    private let quantityLabel: UILabel = {
//        let label = UILabel()
//        label.text = "양"
//        label.font = .body3
//        label.textColor = .black
//        return label
//    }()
    
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
//        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray600.color
        label.textColor = .black
        return label
    }()

    private var menuNameLabel: UILabel = {
        let label = UILabel()
        label.text = "계란국"
        label.font = .caption3
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

    /// 맛 별점
//    lazy var tasteStackView: UIStackView = {
//        let stackView = UIStackView(arrangedSubviews: [tasteLabel, tasteRateView])
//        stackView.axis = .horizontal
//        stackView.spacing = 4.adjusted
//        stackView.alignment = .center
//        return stackView
//    }()

    /// 양 별점
//    lazy var quantityStackView: UIStackView = {
//        let stackView = UIStackView(arrangedSubviews: [quantityLabel, quantityRateView])
//        stackView.axis = .horizontal
//        stackView.spacing = 4.adjusted
//        stackView.alignment = .center
//        return stackView
//    }()

    /// 별점
    lazy var rateStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [totalRateView/*, tasteStackView, quantityStackView*/])
        stackView.axis = .horizontal
        stackView.spacing = 8.adjusted
        stackView.alignment = .center
        return stackView
    }()

    /// 이름 + 메뉴
    lazy var nameMenuStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [userNameLabel, menuNameLabel])
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

//    lazy var contentStackView: UIStackView = {
//        let stackView = UIStackView(arrangedSubviews: [reviewTextView, foodImageView])
//        stackView.axis = .vertical
//        stackView.spacing = 8.adjusted
//        stackView.alignment = .leading
//        return stackView
//    }()

    // MARK: - Functions

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(profileStackView)
        contentView.addSubview(dateReportStackView)
        contentView.addSubview(contentStackView)
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
            make.height.width.equalTo(358)
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
    func dataBind(response: MenuDataList) {
        menuNameLabel.text = response.menu
        menuName = response.menu
        userNameLabel.text = response.writerNickname
        totalRateView.setRating(response.mainRating)
//        totalRateView.rateNumberLabel.text = "\(response.mainRating)"
        
//        if response.tasteRating == nil {
//            tasteStackView.isHidden = true
//        } else {
//            tasteStackView.isHidden = false
//            tasteRateView.rateNumberLabel.text = "\(response.tasteRating ?? 0)"
//        }
        
//        if response.amountRating == nil {
//            quantityStackView.isHidden = true
//        } else {
//            quantityStackView.isHidden = false
//            quantityRateView.rateNumberLabel.text = "\(response.amountRating ?? 0)"
//        }
        dateLabel.text = response.writedAt
        reviewTextView.text = response.content
        reviewId = response.reviewID
        if let firstImageUrl = response.imgURLList.compactMap({ $0 }).first(where: { !$0.isEmpty }) {
            foodImageView.isHidden = false
            foodImageView.kfSetImage(url: firstImageUrl)
        } else {
            foodImageView.isHidden = true
        }
        sideButton.setImage(EATSSUDesignAsset.Images.icMenu.image, for: .normal)
        sideButton.addTarget(self, action: #selector(touchedSideButtonEvent), for: .touchUpInside)
        
        
//        tags = (response.tags ?? []).map { ($0.name, $0.isLiked) }
//        tags = (response.tags ?? [Tag(name: "기본태그", isLiked: true),
//                                      Tag(name: "추천", isLiked: false)])
//                    .map { ($0.name, $0.isLiked) }
        tagCollectionView.reloadData()
        
    }

    func myPageDataBind(response: MyDataList, nickname: String) {
        userNameLabel.text = "\(nickname)"
        menuNameLabel.text = response.menuName
        totalRateView.rateNumberLabel.text = "\(response.mainRating)"
//        if response.tasteRating == nil {
//            tasteStackView.isHidden = true
//        } else {
//            tasteStackView.isHidden = false
//            tasteRateView.rateNumberLabel.text = "\(response.tasteRating ?? 0)"
//        }
        
//        if response.amountRating == nil {
//            quantityStackView.isHidden = true
//        } else {
//            quantityStackView.isHidden = false
//            quantityRateView.rateNumberLabel.text = "\(response.amountRating ?? 0)"
//        }
        dateLabel.text = response.writeDate
        reviewTextView.text = response.content
        if response.imgURLList.count != 0 {
            if response.imgURLList[0] != "" {
                foodImageView.isHidden = false
                foodImageView.kfSetImage(url: response.imgURLList[0])
            }
        } else {
            foodImageView.isHidden = true
        }
        sideButton.addTarget(self, action: #selector(touchedSideButtonEvent), for: .touchUpInside)
        sideButton.setImage(EATSSUDesignAsset.Images.icMenu.image, for: .normal)
        sideButton.setTitle("", for: .normal)
        reviewId = response.reviewID
    }
}
