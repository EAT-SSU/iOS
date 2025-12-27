//
//  MenuLikeCell.swift
//  EatSSU-iOS
//
//  Created by 한금준 on 9/28/25.
//

import UIKit
import SnapKit

import EATSSUDesign

final class MenuLikeCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "MenuLikeCell"
    
    var onLikeTapped: (() -> Void)?
    var isLiked: Bool = false {
        didSet {
            updateLikeState()
        }
    }
    
    // MARK: - UI Components
    
    /// 메뉴 이름 레이블
    private let menuLabel: UILabel = {
        let label = UILabel()
        label.font = .body3
        label.textColor = .black
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    /// 좋아요 버튼 이미지
    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .gray
        button.backgroundColor = .clear
        button.isUserInteractionEnabled = false
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    /// 좋아요 버튼 컨테이너
    private let likeContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1
        view.layer.borderColor = EATSSUDesignAsset.Color.GrayScale.gray300.color.cgColor
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        return view
    }()
    
    /// 스택뷰 (메뉴 레이블 + 좋아요 컨테이너)
    private lazy var hStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [menuLabel, likeContainer])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setLayout()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration

    private func setupUI() {
        selectionStyle = .none
        
        contentView.addSubview(hStack)
        likeContainer.addSubview(likeButton)
    }

    private func setLayout() {
        hStack.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(12).priority(.high)
            $0.horizontalEdges.equalToSuperview()
        }
        
        likeContainer.snp.makeConstraints {
            $0.height.equalTo(28).priority(.high)
            $0.width.equalTo(58).priority(.required)
        }
        
        likeButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(CGSize(width: 18, height: 18))
        }
    }

    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        likeContainer.isUserInteractionEnabled = true
        likeContainer.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    /// 좋아요 버튼 탭 처리
    @objc private func likeTapped() {
        onLikeTapped?()
    }
    
    // MARK: - Public Methods
    
    /// 셀 데이터 바인딩
    /// - Parameters:
    ///   - menu: 메뉴 이름
    ///   - isLiked: 좋아요 상태
    func dataBind(menu: String, isLiked: Bool) {
        menuLabel.text = menu
        self.isLiked = isLiked
    }
    
    // MARK: - Private Methods
    
    /// 좋아요 상태에 따른 UI 업데이트
    private func updateLikeState() {
        
        let image = isLiked
            ? EATSSUDesignAsset.Images.thumbUp.image
            : EATSSUDesignAsset.Images.thumbUpGray.image
        
        DispatchQueue.main.async {
            let resizedImage = image.withRenderingMode(.alwaysOriginal)
            self.likeButton.setImage(resizedImage, for: .normal)
            
            if self.isLiked {
                self.likeContainer.backgroundColor = EATSSUDesignAsset.Color.Main.secondary.color
                self.likeContainer.layer.borderColor = EATSSUDesignAsset.Color.Main.primary.color.cgColor
            } else {
                self.likeContainer.backgroundColor = .clear
                self.likeContainer.layer.borderColor = EATSSUDesignAsset.Color.GrayScale.gray300.color.cgColor
            }
        }
    }
}
