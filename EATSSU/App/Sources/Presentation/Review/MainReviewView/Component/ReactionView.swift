//
//  ReactionView.swift
//  EATSSU
//
//  Created by 최지우 on 2/11/25.
//

import UIKit

import EATSSUDesign
import SnapKit

final class ReactionView: BaseUIView {
    
    // MARK: - UI Components
    
    private let likeImageView: UIImageView = {
        let imageView = UIImageView(image: EATSSUDesignAsset.Images.like.image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let likeCountLabel: UILabel = {
        let label = UILabel()
        label.text = "3"
        label.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 12)
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [likeImageView, likeCountLabel])
        stackView.axis = .horizontal
        stackView.spacing = 3
        return stackView
    }()
    
    // MARK: - Functions
    
    override func configureUI() {
        addSubview(stackView)
    }
    
    override func setLayout() {
        stackView.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
    }
}
