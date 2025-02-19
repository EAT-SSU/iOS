//
//  ThumbsCountView.swift
//  EATSSU
//
//  Created by 최지우 on 2/18/25.
//

import UIKit

import EATSSUDesign
import SnapKit

enum ThumbType {
    case up
    case down
}

final class ThumbsCountView: BaseUIView {
    
    // MARK: - Properties
    
    private let thumbType: ThumbType

    // MARK: - UI Components
    
    private let thumbImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = EATSSUDesignFontFamily.Pretendard.semiBold.font(size: 16)
        label.text = "12"
        return label
    }()
    
    // MARK: - Functions
    
    init(thumbType: ThumbType) {
        self.thumbType = thumbType
        super.init(frame: .zero)
        setThumbImage()
    }
    
    override func configureUI() {
        addSubviews(thumbImageView,
                    countLabel)
    }
    
    override func setLayout() {
        thumbImageView.snp.makeConstraints { make in
            make.height.width.equalTo(16)
            make.top.leading.equalToSuperview()
        }
        countLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.leading.equalTo(thumbImageView.snp.trailing).offset(11)
        }
    }
    
    private func setThumbImage() {
        switch thumbType {
        case .up:
            thumbImageView.image = EATSSUDesignAsset.Images.filledThumbUp.image
        case .down:
            thumbImageView.image = EATSSUDesignAsset.Images.filledThumbDown.image
        }
    }
    
    public func updateCount(thumbCnt: Int) {
        countLabel.text = "\(thumbCnt)"
    }

}
