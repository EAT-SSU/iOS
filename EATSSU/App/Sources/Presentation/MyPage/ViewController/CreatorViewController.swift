//
//  CreatorViewController.swift
//  EATSSU
//
//  Created by Jiwoong CHOI on 9/11/24.
//

// Swift Module
import UIKit

// External Module
import SnapKit

import EATSSUDesign

class CreatorViewController: BaseViewController {
    override var shouldHideTabBar: Bool { true }
    // MARK: - Properties
    private enum URLConstants {
        static let instagram = "https://www.instagram.com/eatssu.official/"
        static let landingPage = "https://eat-ssu.notion.site/eat-ssu-landing"
    }

    // View Properties
    private let creatorsView = CreatorsView()

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        logScreenView(screenID: FirebaseScreenID.MyPage.mypage2)
        setUpAction()
        applyGradientBackground()
        view.layoutIfNeeded()
    }

    // MARK: - Methods

    override func configureUI() {
        view.addSubview(creatorsView)
    }

    override func setLayout() {
        creatorsView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(66)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.bottom.equalToSuperview()
        }
    }

    override func setCustomNavigationBar() {
        // TODO: setCustomNavigationBar에 파라미터로 title 값을 받아서 네비게이션 바를 설계하도록 변경
        super.setCustomNavigationBar()
        navigationItem.title = TextLiteral.MyPage.creators
    }
    
    private func applyGradientBackground() {
        if let existing = view.layer.sublayers?.first(where: { $0.name == "gradientLayer" }) {
            existing.frame = view.bounds
            return
        }

        let gradient = CAGradientLayer()
        gradient.name = "gradientLayer"
        gradient.frame = view.bounds
        gradient.colors = [
            UIColor.highGradation.cgColor,
            UIColor.lowGradation.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(gradient, at: 0)
    }

    private func setUpAction() {
        /// @eatssu_official 인스타그램 연결
        let instagramTapGesture = UITapGestureRecognizer(target: self, action: #selector(openInstagram))
        creatorsView.instagramStackView.addGestureRecognizer(instagramTapGesture)
           

        /// eatssu 랜딩페이지 연결
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(nextCreatorsImageTapped))
        creatorsView.nextCreatorsImageView.addGestureRecognizer(tapGesture)
    }

    private func open(urlString: String) {
        guard let url = URL(string: urlString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    /// @eatssu_official 인스타그램 연결 동작
    @objc private func openInstagram() {
        AnalyticsService.logEvent("click_creator_link", parameters: ["type": "instagram"])
        open(urlString: URLConstants.instagram)
    }

    /// eatssu 랜딩페이지 연결 동작
    @objc private func nextCreatorsImageTapped() {
        AnalyticsService.logEvent("click_creator_link", parameters: ["type": "landing_page"])
        open(urlString: URLConstants.landingPage)
    }
}
