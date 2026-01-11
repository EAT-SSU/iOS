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

    var menuTableViewHeightConstraint: Constraint?
    
    // MARK: - UI Components

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    let contentView: UIView = UIView()

    let menuLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.Review.rateTodayMeal
        label.font = .subtitle1
        label.textColor = .black
        return label
    }()
    
    let rateView = RateView()

    let detailLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.Review.recommendMenu
        label.font = .subtitle1
        label.textColor = .black
        return label
    }()
    
    let menuTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = false
        tableView.rowHeight = 48.adjusted
        return tableView
    }()

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

    let selectImageButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.image = EATSSUDesignAsset.Images.addImageButton.image
        config.imagePlacement = .top
        config.imagePadding = 3.5
        config.image?.withTintColor(EATSSUDesignAsset.Color.GrayScale.gray300.color)
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 0, bottom: 19, trailing: 0)
        button.configuration = config
        button.layer.borderWidth = 1
        button.layer.borderColor = EATSSUDesignAsset.Color.GrayScale.gray500.color.cgColor
        button.backgroundColor = EATSSUDesignAsset.Color.GrayScale.gray100.color
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        return button
    }()
    
    let imageCountLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.Review.photoCount
        label.font = .caption3
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray400.color
        label.textAlignment = .center
        return label
    }()
    
    let userReviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        imageView.isHidden = true
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
        label.text = TextLiteral.Review.deletePhoto
        label.font = .caption3
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray500.color
        return label
    }()

    let buttonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 0
        view.clipsToBounds = true
        return view
    }()
    
    let nextButton: MainButton = {
        let button = MainButton()
        button.title = TextLiteral.Review.leaveReview
        return button
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupLayout()
  
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
            userReviewImageView,
            closeButton,
            deleteMethodLabel
        )
        
        selectImageButton.addSubview(imageCountLabel)

        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(buttonContainer.snp.top)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        buttonContainer.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(80)
        }
        
        nextButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.top.equalToSuperview().offset(12)
        }

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
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(4)
            $0.bottom.equalToSuperview().inset(7)
        }
        
        userReviewImageView.snp.makeConstraints {
            $0.top.equalTo(maximumWordLabel.snp.bottom).offset(15)
            $0.leading.equalTo(selectImageButton.snp.trailing).offset(13)
            $0.width.height.equalTo(60)
        }
        
        deleteMethodLabel.snp.makeConstraints {
            $0.top.equalTo(selectImageButton.snp.bottom).offset(9)
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

    func setInitialTextViewState() {
        userReviewTextView.text = TextLiteral.Review.inputDetailReview
        userReviewTextView.textColor = EATSSUDesignAsset.Color.GrayScale.gray500.color
        userReviewTextView.font = .body2
    }

    func updateImageViewState(image: UIImage?, count: Int, isHidden: Bool) {
        userReviewImageView.image = image
        userReviewImageView.isHidden = isHidden
        closeButton.isHidden = isHidden || (image == nil)
        imageCountLabel.text = TextLiteral.Review.photoCount(count: count)
    }
}
