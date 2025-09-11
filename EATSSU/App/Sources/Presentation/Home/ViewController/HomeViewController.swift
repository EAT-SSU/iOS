//
//  HomeViewController.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/08/08.
//

import UIKit

import FirebaseAnalytics
import Moya
import SnapKit

import EATSSUDesign

final class HomeViewController: BaseViewController {
    // MARK: - Properties

    private var currentDate = Date() {
        didSet {
            #if DEBUG
                print("Changed Date: \(currentDate)")
            #endif
        }
    }
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: EATSSUDesignAsset.Images.mainLogoSmall.image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let tabmanController = CustomTimeTabController()
    private let homeCalendarView = HomeCalendarView()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setupDelegates()
        configureUI()
        setLayout()
        registerTabman()
        
        // 이미 등록된 옵저버가 있으면 먼저 제거
        NotificationCenter.default.removeObserver(self, name: .didEnterNewDay, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewDayNotification(_:)),
            name: .didEnterNewDay,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didEnterNewDay, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logFirebaseEvent()
        
        Analytics.logEvent(AnalyticsEventScreenView,
                           parameters: [AnalyticsParameterScreenName: FirebaseScreenID.Home.home1,
                                                    AnalyticsParameterScreenClass: "HomeViewController"])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - UI Configuration

    override func configureUI() {
        view.addSubview(logoImageView)
        view.addSubview(homeCalendarView)
    }

    override func setLayout() {
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide) 
            make.centerX.equalToSuperview()
            make.height.equalTo(28)
        }

        homeCalendarView.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(13)
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
    
    @objc private func handleNewDayNotification(_ notification: Notification) {
        // 백그라운드에서 돌아와 새로운 날로 판단될 때, 오늘 날짜로 갱신
        DispatchQueue.main.async {
            let today = Date()
            self.currentDate = today
            // 달력뷰에 오늘 날짜가 선택되도록 호출
            self.homeCalendarView.setSelected(date: today)
        }
    }
}

// MARK: - Calendar Selection Delegate

extension HomeViewController: CalendarSeletionDelegate {
    func didSelectCalendar(date: Date) {
        currentDate = date
    }
}
