//
//  ReviewListTableViewHeader.swift
//  EATSSU-DEV
//
//  Created by 최지우 on 2/2/25.
//

import UIKit
import SnapKit

import EATSSUDesign

final class ReviewListTableViewHeader: UITableViewHeaderFooterView {
    static let id = "ReviewListTableViewHeader"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "리뷰"
        label.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 18)
        return label
    }()
    
    private let reviewImageThumbnailView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()
    
    private let reviewThumbnailImageView: UIImageView = {
        let imageView = UIImageView(image: EATSSUDesignAsset.Images.reviewPhotoDummy.image)
        return imageView
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        configureUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        reviewImageThumbnailView.addSubview(reviewThumbnailImageView)
        addSubviews(titleLabel,
                    reviewImageThumbnailView)
        
    }
    
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.left.top.right.equalToSuperview()
        }
        reviewImageThumbnailView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.height.equalTo(90)
        }
        reviewThumbnailImageView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12)
            make.width.equalTo(reviewThumbnailImageView.snp.height)
        }
    }
}
