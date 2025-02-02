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
    
    
    /// user
    // MARK: - Properties
    
    var handler: (() -> Void)?
    var reviewId: Int = .init()
    var menuName: String = .init()
    
    // MARK: - UI Components
    
    lazy var totalRateView = RateNumberView()
    
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
        return label
    }()
    
    private var menuNameLabel: UILabel = {
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
//        button.setImage(EATSSUDesignAsset.Images.icInfo.image, for: .normal)
        button.setTitleColor(EATSSUDesignAsset.Color.GrayScale.gray400.color, for: .normal)
        button.titleLabel?.font = .caption2
        button.setTitle("신고", for: .normal)
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
        let stackView = UIStackView(arrangedSubviews: [nameMenuStackView, totalRateView])
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
        stackView.alignment = .leading
        return stackView
    }()
    
    lazy var dateReportStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [sideButton, dateLabel])
        stackView.axis = .vertical
        stackView.spacing = 11.adjusted
        stackView.alignment = .trailing
        return stackView
    }()
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [reviewTextLabel, foodImageView])
        stackView.axis = .vertical
        stackView.spacing = 8.adjusted
        stackView.alignment = .leading
        return stackView
    }()
    
    /// other
    
    private let titleLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 15)
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 2.0
        layout.minimumInteritemSpacing = 5.0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.backgroundColor = .red
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    // MARK: - Functions
    
    private func setCollectionView() {
        collectionView.register(MenuChipCollectionViewCell.self,
                                forCellWithReuseIdentifier: MenuChipCollectionViewCell.id)
    }
    
    override func configureUI() {
        setCollectionView()
        contentView.addSubviews(profileStackView,
                                dateReportStackView,
                                collectionView,
                                contentStackView)
    }
    
    override func setLayout() {
        profileStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(50)
        }
        
        dateReportStackView.snp.makeConstraints { make in
            make.top.equalTo(profileStackView)
            make.trailing.equalToSuperview().inset(16)
        }
        
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        
        foodImageView.snp.makeConstraints { make in
            make.height.width.equalTo(358)
        }
        
        sideButton.snp.makeConstraints {
            $0.height.equalTo(12.adjusted)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(profileStackView.snp.bottom).offset(8)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(22)
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
        self.titleLabel.text = review
        self.menuChipList = menuChipList
        self.collectionView.reloadData()
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
