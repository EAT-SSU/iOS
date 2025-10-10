//
//  MenuLikeCell.swift
//  EATSSU
//
//  Created by 한금준 on 9/28/25.
//

import UIKit
import SnapKit

import EATSSUDesign

final class MenuLikeCell: UITableViewCell {
    static let identifier = "MenuLikeCell"
    
    // MARK: - Properties
    var onLikeTapped: (() -> Void)?
    var isLiked: Bool = false {
        didSet {
            tapped()   // 상태값 변경 시 UI 갱신
        }
    }
    
    // MARK: - UI Components
    private let menuLabel: UILabel = {
        let label = UILabel()
        label.font = .body3
        label.textColor = .black
        return label
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .gray
        button.backgroundColor = .clear
        button.isUserInteractionEnabled = false
        return button
    }()

    private let likeContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1
        view.layer.borderColor = EATSSUDesignAsset.Color.GrayScale.gray300.color.cgColor
        return view
    }()
    
    private lazy var hStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [menuLabel, likeContainer])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        contentView.addSubview(hStack)
        likeContainer.addSubview(likeButton)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        likeContainer.isUserInteractionEnabled = true
        likeContainer.addGestureRecognizer(tapGesture)

        hStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func likeTapped() {
        onLikeTapped?()
    }
    
    // MARK: - Public Functions
    func dataBind(menu: String, isLiked: Bool) {
        menuLabel.text = menu
        self.isLiked = isLiked
    }
    
    private func tapped() {
        print("tapped 실행됨 → isLiked:", isLiked)
        let image = isLiked ? EATSSUDesignAsset.Images.thumbUp.image : EATSSUDesignAsset.Images.thumbUpGray.image
        DispatchQueue.main.async {
                self.likeButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
                
                // Container 스타일 업데이트
                if self.isLiked {
                    self.likeContainer.backgroundColor = EATSSUDesignAsset.Color.Main.secondary.color
                    self.likeContainer.layer.borderColor = EATSSUDesignAsset.Color.Main.primary.color.cgColor
                } else {
                    self.likeContainer.backgroundColor = .clear
                    self.likeContainer.layer.borderColor = EATSSUDesignAsset.Color.GrayScale.gray500.color.cgColor
                }
            }
    }
}

