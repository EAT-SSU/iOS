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
    private var buttonBottomConstraint: Constraint?
    private var imageBottomConstraint: Constraint?

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
        tableView.rowHeight = 44.adjusted
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
        label.text = TextLiteral.Review.characterCount(current: 0, max: 300)
        label.font = .caption3
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray500.color
        return label
    }()

    let selectImageButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "camera.fill")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        )
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.attributedTitle = AttributedString(
            TextLiteral.Review.addPhoto(count: 0),
            attributes: AttributeContainer([.font: UIFont.body2, .foregroundColor: UIColor.black])
        )
        config.baseForegroundColor = .black
        button.configuration = config
        button.layer.borderWidth = 1
        button.layer.borderColor = EATSSUDesignAsset.Color.GrayScale.gray300.color.cgColor
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        return button
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
        let symbolConfig = UIImage.SymbolConfiguration(paletteColors: [
            .white,
            EATSSUDesignAsset.Color.GrayScale.gray600.color
        ])
        let image = UIImage(systemName: "minus.circle.fill")?.applyingSymbolConfiguration(symbolConfig)
        button.setImage(image, for: .normal)
        button.isHidden = true
        return button
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
            closeButton
        )

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
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(60)
            self.buttonBottomConstraint = $0.bottom.equalTo(contentView.snp.bottom).offset(-50).constraint
        }

        userReviewImageView.snp.makeConstraints {
            $0.top.equalTo(maximumWordLabel.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(80)
            self.imageBottomConstraint = $0.bottom.equalTo(contentView.snp.bottom).offset(-50).constraint
        }
        imageBottomConstraint?.deactivate()

        closeButton.snp.makeConstraints {
            $0.top.equalTo(userReviewImageView.snp.top).offset(-6)
            $0.trailing.equalTo(userReviewImageView.snp.trailing).offset(6)
            $0.size.equalTo(24)
        }
    }

    private func updateContentBottomConstraint() {
        let hasImage = !userReviewImageView.isHidden
        buttonBottomConstraint?.isActive = !hasImage
        imageBottomConstraint?.isActive = hasImage
    }

    // MARK: - Public Methods

    func setInitialTextViewState() {
        userReviewTextView.text = TextLiteral.Review.inputDetailReview
        userReviewTextView.textColor = EATSSUDesignAsset.Color.GrayScale.gray500.color
        userReviewTextView.font = .body2
    }

    func updateImageViewState(image: UIImage?, count: Int, isHidden: Bool) {
        userReviewImageView.image = image

        let hasImage = !isHidden && image != nil
        userReviewImageView.isHidden = !hasImage
        closeButton.isHidden = !hasImage
        selectImageButton.isHidden = hasImage

        var config = selectImageButton.configuration
        config?.attributedTitle = AttributedString(
            TextLiteral.Review.addPhoto(count: count),
            attributes: AttributeContainer([.font: UIFont.body2, .foregroundColor: UIColor.black])
        )
        selectImageButton.configuration = config

        updateContentBottomConstraint()
    }
}
