//
//  CreatorsView.swift
//  EATSSU
//
//  Created by Jiwoong CHOI on 9/11/24.
//

// Swift Module
import UIKit

// External Module
import SnapKit

/// "만든 사람들"을 담고 있는 View 입니다.
class CreatorsView: BaseUIView {
    // MARK: - UI Components

    private let creatorsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUAsset.Images.Version2.creators.image
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
            make.width.equalTo(342)
            make.height.equalTo(689)
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
        addSubview(creatorsImageView)
    }

    override func setLayout() {
        creatorsImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
