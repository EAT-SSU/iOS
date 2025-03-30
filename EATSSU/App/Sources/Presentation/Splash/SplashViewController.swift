//
//  SplashViewController.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 3/25/25.
//

//
//  SplashViewController.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 3/25/25.
//

import UIKit

import EATSSUDesign

import SnapKit
import Then

/// 기본 스플래시 뷰
class SplashViewController: BaseViewController {
    // MARK: - UI Components
    private let logoImageView = UIImageView().then {
        $0.image = EATSSUDesignAsset.Images.splashLogo.image
        $0.contentMode = .scaleAspectFit
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = EATSSUDesignAsset.Color.Main.primary.color
    }

    // MARK: - UI Setup
    override func configureUI() {
        view.addSubview(logoImageView)
    }

    override func setLayout() {
        logoImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(230)
            $0.height.equalTo(75)
        }
    }
}
