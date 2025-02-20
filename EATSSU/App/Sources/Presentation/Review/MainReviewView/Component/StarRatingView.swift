//
//  StarRatingView.swift
//  EATSSU
//
//  Created by 최지우 on 2/20/25.
//

import UIKit

import SnapKit
import EATSSUDesign

final class StarRatingView: BaseUIView {
    
    // MARK: - Properties
    
    private let maxStars = 5
    
    public var rating: Int = 0 {
        didSet {
            updateStarImages()
        }
    }
    
    // MARK: - UI Components
    
    private var starImageViews: [UIImageView] = []
    
    // MARK: - Functions
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        for _ in 0..<maxStars {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.image = EATSSUDesignAsset.Images.icStarGray.image
            imageView.snp.makeConstraints { make in
                make.width.height.equalTo(12)
            }
            starImageViews.append(imageView)
            stackView.addArrangedSubview(imageView)
        }
    }
    
    private func updateStarImages() {
        for (index, imageView) in starImageViews.enumerated() {
            if index < rating {
                imageView.image = EATSSUDesignAsset.Images.icStarYellow.image
            } else {
                imageView.image = EATSSUDesignAsset.Images.icStarGray.image
            }
        }
    }
}
