//
//  SetRateView.swift
//  EATSSU
//
//  Created by 한금준 on 11/29/25.
//

import UIKit
import SnapKit

import EATSSUDesign

final class SetRateView: UIView {
    
    // MARK: - Properties
    
    /// 메뉴 테이블뷰 높이 제약조건 (Controller에서 content size에 따라 업데이트)
    var menuTableViewHeightConstraint: Constraint?
    
    // MARK: - UI Components
    
    // Scroll View Container
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    let contentView: UIView = UIView()
    
    // Review Rate Section
    let menuLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘의 식사는 어떠셨나요?"
        label.font = .subtitle1
        label.textColor = .black
        return label
    }()
    
    let rateView = RateView()
    
    // Menu Like Section
    let detailLabel: UILabel = {
        let label = UILabel()
        label.text = "추천하고 싶은 메뉴가 있나요?"
        label.font = .subtitle1
        label.textColor = .black
        return label
    }()
    
    let menuTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = false // 높이를 content size에 맞춤
        tableView.rowHeight = 48.adjusted // Cell height
        return tableView
    }()
    
    // Review Text Section
    let userReviewTextView: UITextView = {
        let textView = UITextView()
        textView.font = .body1
        textView.layer.cornerRadius = 10.adjusted
        textView.backgroundColor = EATSSUDesignAsset.Color.GrayScale.gray100.color
        textView.layer.borderWidth = 1.adjusted
        textView.layer.borderColor = EATSSUDesignAsset.Color.GrayScale.gray300.color.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 16.0.adjusted, left: 16.0.adjusted, bottom: 16.0.adjusted, right: 16.0.adjusted)
        return textView
    }()
    
    let maximumWordLabel: UILabel = {
        let label = UILabel()
        label.text = "0 / 300"
        label.font = .caption3
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray500.color
        return label
    }()
    
    // Image Section
    let selectImageButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.image = EATSSUDesignAsset.Images.addImageButton.image
        config.contentInsets = NSDirectionalEdgeInsets(top: -5, leading: 0, bottom: 5, trailing: 0)
        button.configuration = config
        button.layer.borderWidth = 1
        button.layer.borderColor = EATSSUDesignAsset.Color.GrayScale.gray500.color.cgColor
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }()
    
    let imageCountLabel: UILabel = {
        let label = UILabel()
        label.text = "사진 0/1"
        label.font = .caption3
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray500.color
        label.textAlignment = .center
        return label
    }()
    
    let userReviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true // Controller에서 제스처 추가
        imageView.contentMode = .scaleAspectFill
        imageView.isHidden = true // 초기 상태 숨김
        return imageView
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .lightGray
        button.isHidden = true
        return button
    }()
    
    let deleteMethodLabel: UILabel = {
        let label = UILabel()
        label.text = "사진 클릭 시, 삭제됩니다"
        label.font = .caption3
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray500.color
        return label
    }()
    
    // Bottom Button Section
    let buttonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 0
        view.clipsToBounds = true
        return view
    }()
    
    let nextButton: MainButton = {
        let button = MainButton()
        button.title = "리뷰 남기기"
        return button
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupLayout()
        // 뷰 초기 상태 설정
        setInitialTextViewState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        self.backgroundColor = .white
    }
    
    private func setupLayout() {
        self.addSubviews(scrollView, buttonContainer)
        
        buttonContainer.addSubview(nextButton)
        scrollView.addSubview(contentView)
        contentView.addSubviews(
            rateView,
            menuLabel,
            detailLabel,
            menuTableView,
            userReviewTextView,
            maximumWordLabel,
            selectImageButton,
            imageCountLabel,
            userReviewImageView,
            closeButton,
            deleteMethodLabel
        )
        
        // 1. ScrollView & ContentView
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(buttonContainer.snp.top)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        // 2. Bottom Button
        buttonContainer.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(80)
        }
        
        nextButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.top.equalToSuperview().offset(12)
        }
        
        // 3. Main Content
        menuLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }
        
        rateView.snp.makeConstraints { make in
            make.top.equalTo(menuLabel.snp.bottom).offset(17)
            make.centerX.equalToSuperview()
            make.height.equalTo(36.12)
        }
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(rateView.snp.bottom).offset(35)
            make.centerX.equalToSuperview()
        }
        
        menuTableView.snp.makeConstraints {
            $0.top.equalTo(detailLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
            // 초기 높이 제약조건 설정 (Controller에서 업데이트)
            self.menuTableViewHeightConstraint = $0.height.equalTo(0).constraint
        }
        
        userReviewTextView.snp.makeConstraints { make in
            make.top.equalTo(menuTableView.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(181)
        }
        
        maximumWordLabel.snp.makeConstraints { make in
            make.top.equalTo(userReviewTextView.snp.bottom).offset(7)
            make.trailing.equalTo(userReviewTextView)
        }
        
        selectImageButton.snp.makeConstraints {
            $0.top.equalTo(maximumWordLabel.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(60)
        }
        
        imageCountLabel.snp.makeConstraints {
            $0.top.equalTo(selectImageButton.snp.bottom).offset(5)
            $0.centerX.equalTo(selectImageButton)
        }
        
        userReviewImageView.snp.makeConstraints {
            $0.top.equalTo(maximumWordLabel.snp.bottom).offset(15)
            $0.leading.equalTo(selectImageButton.snp.trailing).offset(13)
            $0.width.height.equalTo(60)
        }
        
        deleteMethodLabel.snp.makeConstraints {
            $0.top.equalTo(imageCountLabel.snp.bottom).offset(7)
            $0.leading.equalTo(selectImageButton)
            $0.bottom.equalTo(contentView.snp.bottom).offset(-50)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(userReviewImageView.snp.top).offset(-6)
            $0.trailing.equalTo(userReviewImageView.snp.trailing).offset(6)
            $0.size.equalTo(24)
        }
    }
    
    // MARK: - Public Methods
    
    /// 리뷰 텍스트뷰의 초기 상태를 설정합니다.
    func setInitialTextViewState() {
        userReviewTextView.text = "메뉴에 대한 상세한 리뷰를 작성해주세요"
        userReviewTextView.textColor = EATSSUDesignAsset.Color.GrayScale.gray500.color
        userReviewTextView.font = .body2
    }
    
    /// 이미지 뷰와 관련 UI를 업데이트합니다.
    func updateImageViewState(image: UIImage?, count: Int, isHidden: Bool) {
        userReviewImageView.image = image
        userReviewImageView.isHidden = isHidden
        closeButton.isHidden = isHidden || (image == nil)
        imageCountLabel.text = "사진 \(count)/1"
    }
}
