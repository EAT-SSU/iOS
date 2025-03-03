//
//  ReviewListTableViewCell.swift
//  EATSSU-DEV
//
//  Created by 최지우 on 2/1/25.
//

import UIKit

import SnapKit
import EATSSUDesign

final class ReviewListTableViewCell: BaseTableViewCell {
    static let id = "ReviewListTableViewCell"
    private var menuChipList = [String]()
        
    // MARK: - Properties
    
    var handler: (() -> Void)?
    var reviewId: Int = .init()
    var menuName: String = .init()
    
    // MARK: - UI Components
    
    lazy var starRatingView = StarRatingView()
    lazy var reactionView = ReactionView()
    
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "2023.03.03"
        label.font = .caption3
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray400.color
        return label
    }()
    
    private var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "hellosoongsil1234"
        label.font = .caption1
        return label
    }()
    
    private var nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "깐깐슈"
        label.font = .caption3
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray600.color
        return label
    }()
    
    private let userProfileImageView: UIImageView = {
        let imageView = UIImageView(image: EATSSUDesignAsset.Images.profile.image)
        return imageView
    }()
    
    private var sideButton: BaseButton = {
        let button = BaseButton()
        button.setTitleColor(EATSSUDesignAsset.Color.GrayScale.gray400.color, for: .normal)
        button.titleLabel?.font = .caption2
        button.setTitle("신고", for: .normal)
//        button.setImage(EATSSUDesignAsset.Images.icInfo.image, for: .normal)
        button.configuration?.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 15)
        return button
    }()
    
    var reviewTextLabel: UILabel = {
        let label = UILabel()
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 14)
        label.text = "여기 계란국 맛집임... 김치볶음밥에 계란후라이 없어서 아쉽 다음에 또 먹어야지dddddfdfdfdfdfdfddfdfdfddfdfdfdfddfddfdfd여기 계란국 맛집임... 김치볶음밥에 계란후라이 없어서 아쉽 다음에 또 먹어야지dddddfdfdfdfdfdfddfdfdfddfdfdfdfddfddfdfd"
        label.numberOfLines = 0
        return label
    }()
    
    var foodImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    /// 이름 + 닉네임
    lazy var nameMenuStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [userNameLabel, nickNameLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8.adjusted
        stackView.alignment = .center
        return stackView
    }()
    
    /// (이름 + 닉네임) + 별점
    lazy var infoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameMenuStackView, starRatingView])
        stackView.axis = .vertical
        stackView.spacing = 4.adjusted
        stackView.alignment = .leading
        return stackView
    }()
    
    /// 프로필 + (이름 + 닉네임 + 별점)
    lazy var profileStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [userProfileImageView, infoStackView])
        stackView.axis = .horizontal
        stackView.spacing = 8.adjusted
        stackView.alignment = .leading
        stackView.backgroundColor = .purple
        return stackView
    }()
    
    /// 작성일 + 사이드버튼
    lazy var dateReportStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [sideButton, dateLabel])
        stackView.axis = .vertical
        stackView.spacing = 8.adjusted
        stackView.alignment = .trailing
        stackView.backgroundColor = .brown
        return stackView
    }()
    
    /// profileStackView + dateReportStackView
    lazy var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [profileStackView, dateReportStackView])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.backgroundColor = .yellow
        return stackView
    }()
    
    /// 리뷰 텍스트 + 리뷰 이미지
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [reviewTextLabel, foodImageView])
        stackView.axis = .vertical
        stackView.spacing = 8.adjusted
        stackView.alignment = .leading
        stackView.backgroundColor = .primary
        return stackView
    }()
    
    /// 추천 메뉴칩
    private lazy var menuChipCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        // MARK: - TODO
        layout.minimumLineSpacing = 4
//        layout.minimumInteritemSpacing = 60
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.backgroundColor = .red
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    /// 전체 cell
    lazy var cellStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            topStackView,
            menuChipCollectionView,
            contentStackView,
            reactionView,
            dividerView]
        )
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = EATSSUDesignAsset.Color.GrayScale.gray200.color
        return view
    }()
    
    // MARK: - Functions
    
    private func setCollectionView() {
        menuChipCollectionView.register(MenuChipCollectionViewCell.self,
                                forCellWithReuseIdentifier: MenuChipCollectionViewCell.id)
    }
    
    override func configureUI() {
        setCollectionView()
        contentView.addSubviews(cellStackView)
        starRatingView.rating = 4
    }
    
    override func setLayout() {
        cellStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        menuChipCollectionView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(22)
        }
        contentStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
        }
        foodImageView.snp.makeConstraints { make in
            make.height.width.equalTo(358)
        }
        sideButton.snp.makeConstraints { make in
            make.height.equalTo(12.adjusted)
        }
        reactionView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(20)
        }
        dividerView.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.prepare(review: nil, menuChipList: [])
        
        sideButton.setTitle("", for: .normal)
        sideButton.setImage(UIImage(), for: .normal)
        foodImageView.image = UIImage()
        foodImageView.isHidden = true
    }
    
    func prepare(review: String?, menuChipList: [String]) {
        self.userNameLabel.text = review
        self.menuChipList = menuChipList
        self.menuChipCollectionView.reloadData()
    }
    
    @objc
    func touchedSideButtonEvent() {
        handler?()
    }
    
}

extension ReviewListTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuChipList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuChipCollectionViewCell.id, for: indexPath) as! MenuChipCollectionViewCell
        let menuName = self.menuChipList[indexPath.item]
        cell.prepare(name: menuName)
        return cell
    }
}
