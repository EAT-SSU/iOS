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
    
    /// 좋아요 버튼 탭 핸들러 (Controller에게 이벤트 전달)
    var onLikeTapped: (() -> Void)?
    
    /// 좋아요 상태
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
        return label
    }()
    
    /// 좋아요 버튼 이미지
    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .gray
        button.backgroundColor = .clear
        button.isUserInteractionEnabled = false // Container가 이벤트를 받도록 설정
        return button
    }()
    
    /// 좋아요 버튼 컨테이너 (탭 제스처 인식 영역)
    private let likeContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1
        view.layer.borderColor = EATSSUDesignAsset.Color.GrayScale.gray300.color.cgColor
        return view
    }()
    
    /// 가로 스택뷰 (메뉴 레이블 + 좋아요 컨테이너)
    private lazy var hStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [menuLabel, likeContainer])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
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
    
    /// UI 컴포넌트 설정
    private func setupUI() {
        selectionStyle = .none
        
        contentView.addSubview(hStack)
        likeContainer.addSubview(likeButton)
    }
    
    /// 레이아웃 제약조건 설정
    private func setLayout() {
        hStack.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(12)
            $0.horizontalEdges.equalToSuperview() // TableView에서 inset 처리
        }
        
        likeContainer.snp.makeConstraints {
            $0.height.equalTo(28)
            $0.width.equalTo(58)
        }
        
        likeButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(18)
        }
    }
    
    /// 제스처 설정
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        likeContainer.isUserInteractionEnabled = true
        likeContainer.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    /// 좋아요 버튼 탭 처리 (Controller에게 이벤트 전달)
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
    
    /// 좋아요 상태에 따라 UI 업데이트
    private func updateLikeState() {
        
        let image = isLiked
            ? EATSSUDesignAsset.Images.thumbUp.image // 채워진 좋아요
            : EATSSUDesignAsset.Images.thumbUpGray.image // 빈 좋아요
        
        DispatchQueue.main.async {
            // 버튼 이미지 업데이트
            self.likeButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
            
            // 컨테이너 스타일 업데이트
            if self.isLiked {
                self.likeContainer.backgroundColor = EATSSUDesignAsset.Color.Main.secondary.color // 배경색
                self.likeContainer.layer.borderColor = EATSSUDesignAsset.Color.Main.primary.color.cgColor // 테두리 색
            } else {
                self.likeContainer.backgroundColor = .clear // 배경색 제거
                self.likeContainer.layer.borderColor = EATSSUDesignAsset.Color.GrayScale.gray500.color.cgColor // 테두리 색
            }
        }
    }
}
