//
//  SplashViewController.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 3/25/25.
//

import UIKit

import SnapKit

import EATSSUDesign

/// 기본 스플래시 뷰
class SplashViewController: BaseViewController {
    // MARK: - UI Components

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let theme = ThemeManager.shared.appliedTheme
        view.backgroundColor = theme.splashBackgroundColor
        logoImageView.image = theme.splashLogoImage

        if let bgImage = theme.splashBackgroundImage {
            backgroundImageView.image = bgImage
            backgroundImageView.isHidden = false
        } else {
            backgroundImageView.isHidden = true
        }
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
