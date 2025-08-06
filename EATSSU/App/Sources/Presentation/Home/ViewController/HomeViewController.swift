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

    private let tabmanController = CustomTimeTabController()
    private let homeCalendarView = HomeCalendarView()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
        configureUI()
        setLayout()
        registerTabman()
        setupNavigationBar()
        
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

        let rightButton = UIBarButtonItem(
            image: EATSSUDesignAsset.Images.myPageIcon.image,
            style: .plain,
            target: self,
            action: #selector(didTapRightBarButton)
        )
        rightButton.tintColor = EATSSUDesignAsset.Color.Main.primary.color
        navigationItem.rightBarButtonItem = rightButton
        navigationController?.isNavigationBarHidden = false
    }

    @objc
    private func didTapRightBarButton() {
        if RealmService.shared.isAccessTokenPresent() {
            navigateToMyPage()
        } else {
            presentLoginAlert()
        }
    }

    private func navigateToMyPage() {
        let myPageVC = MyPageViewController()
        navigationController?.pushViewController(myPageVC, animated: true)
    }

    private func presentLoginAlert() {
        let alert = UIAlertController(title: "로그인이 필요한 서비스입니다",
                                      message: "로그인 하시겠습니까?",
                                      preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            AuthService.shared.logout()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

//    private func navigateToLogin() {
//        let loginVC = LoginViewController()
//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//           let sceneDelegate = windowScene.delegate as? SceneDelegate,
//           let window = sceneDelegate.window
//        {
//            window.replaceRootViewController(loginVC)
//        }
//    }

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
