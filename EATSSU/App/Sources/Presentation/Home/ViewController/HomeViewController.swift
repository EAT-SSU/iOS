//
//  HomeViewController.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/08/08.
//

import UIKit

import EATSSUDesign

import FirebaseAnalytics
import GoogleMobileAds
import Moya
import SnapKit

final class HomeViewController: BaseViewController {
    // MARK: - Properties

    private var currentDate = Date() {
        didSet {
            #if DEBUG
                print("Changed Date: \(currentDate)")
            #endif
        }
    }

    private let tabmanController = HomeTimeTabmanController()
    private let homeCalendarView = HomeCalendarView()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
        configureUI()
        setLayout()
        registerTabman()
        setupNavigationBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logFirebaseEvent()
    }

    // MARK: - UI Configuration

    override func configureUI() {
        view.addSubview(homeCalendarView)
    }

    override func setLayout() {
        homeCalendarView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }
    }

    // MARK: - Tabman Setup

    private func registerTabman() {
        addChild(tabmanController)
        view.addSubview(tabmanController.view)
        tabmanController.view.snp.makeConstraints { make in
            make.top.equalTo(homeCalendarView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        tabmanController.didMove(toParent: self)
    }

    // MARK: - Navigation

    private func setupNavigationBar() {
        let logoImageView = UIImageView(image: EATSSUDesignAsset.Images.mainLogoSmall.image)
        navigationItem.titleView = logoImageView
        navigationController?.isNavigationBarHidden = false
    }

    // MARK: - Firebase

    private func logFirebaseEvent() {
        FirebaseRemoteConfig.shared.fetchRestaurantInfo()
        #if !DEBUG
            Analytics.logEvent("HomeViewControllerLoad", parameters: nil)
        #endif
    }

    // MARK: - Delegates

    private func setupDelegates() {
        homeCalendarView.delegate = tabmanController
    }
}

// MARK: - Calendar Selection Delegate

extension HomeViewController: CalendarSeletionDelegate {
    func didSelectCalendar(date: Date) {
        currentDate = date
    }
}
