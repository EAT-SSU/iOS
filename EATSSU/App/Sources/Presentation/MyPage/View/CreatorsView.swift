//
//  CreatorsView.swift
//  EATSSU
//
//  Created by Jiwoong CHOI on 9/11/24.
//

import UIKit

import EATSSUDesign

import SnapKit

/// "만든 사람들"을 담고 있는 View 입니다.
class CreatorsView: BaseUIView {
    // MARK: - UI Components
    
    let scrollView: UIScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.contentInsetAdjustmentBehavior = .never 
    }
    
    let contentView: UIView = UIView().then {
        $0.backgroundColor = .clear
    }

    private let creatorsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.creators.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: - Initializer

    init() {
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    override func configureUI() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(creatorsImageView)
    }

    override func setLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview() 
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalToSuperview()
            make.bottom.equalTo(creatorsImageView.snp.bottom).offset(52)
        }
        
        creatorsImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(276)
            make.height.equalTo(1770)
        }
    }
}
