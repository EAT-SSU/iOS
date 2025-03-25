//
//  SplashViewController.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 3/25/25.
//

import Foundation
import UIKit

import EATSSUDesign

import SnapKit
import Then

/// 기본 스플래시 뷰
class SplashViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let logoImageView = UIImageView().then {
        $0.image = UIImage(named: "SplashLogo")
        $0.contentMode = .scaleAspectFit
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupLayout()
    }
    
    // MARK: - UI Setup
    
    private func configureUI() {
        view.backgroundColor = EATSSUDesignAsset.Color.Main.primary.color
    }
    
    private func setupLayout() {
        view.addSubview(logoImageView)
        
        logoImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(230)
            $0.height.equalTo(75)
        }
    }
}
