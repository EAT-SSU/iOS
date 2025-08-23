//
//  SplashViewController.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 3/25/25.
//

import UIKit

import EATSSUDesign
import FirebaseAnalytics
import SnapKit

/// 기본 스플래시 뷰
class SplashViewController: BaseViewController {
    // MARK: - UI Components
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.splashLogo.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = EATSSUDesignAsset.Color.Main.primary.color
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Analytics.logEvent(AnalyticsEventScreenView,
                           parameters: [AnalyticsParameterScreenName: FirebaseScreenID.log1,
                                       AnalyticsParameterScreenClass: "SplashViewController"])
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
