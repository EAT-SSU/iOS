//
//  SplashViewController.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 3/25/25.
//

import UIKit

import SnapKit
import FirebaseAnalytics

import EATSSUDesign

/// 기본 스플래시 뷰
class SplashViewController: BaseViewController {
    // MARK: - UI Components
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.splashChistmasBackground.image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.splashChristmasLogo.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .primary
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        logScreenView(screenID: FirebaseScreenID.Login.log1)
    }

    // MARK: - UI Setup
    override func configureUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(logoImageView)
    }

    override func setLayout() {
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        logoImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(230)
            $0.height.equalTo(75)
        }
    }
}
