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
        imageView.snp.makeConstraints { make in
            make.width.equalTo(276)
            make.height.equalTo(1770)
        }
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
            make.edges.equalToSuperview() // 화면 전체에 ScrollView
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView) // ScrollView 내부에 맞춤
            make.width.equalToSuperview() // 가로 크기는 화면 크기와 동일
            make.bottom.equalTo(creatorsImageView.snp.bottom).offset(52) // 높이 지정
        }
        
        creatorsImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
