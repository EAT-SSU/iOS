//
//  CustomTabBarContainerController.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 6/21/25.
//

import UIKit
import SnapKit

final class CustomTabBarContainerController: BaseViewController {

    // MARK: - Properties

    private let contentContainerView = UIView()
    private let tabBarView = CustomTabBarView()
    private let viewControllers: [UINavigationController] = [
        UINavigationController(rootViewController: HomeViewController()),
        UINavigationController(rootViewController: MainMapViewController()),
        UINavigationController(rootViewController: MyPageViewController())
    ]
    private var currentIndex = 0
    private var contentBottomConstraint: Constraint?
    
    // MARK: - View Setup

    override func configureUI() {
        view.addSubview(contentContainerView)
        view.addSubview(tabBarView)

        tabBarView.buttonTapped = { [weak self] index in
            guard let self = self else { return }

            if index == 1 {
                MapAnalyticsManager.shared.logClickMap()
            }
            
            if (index == 1 || index == 2), RealmService.shared.isAccessTokenPresent() == false {
                self.presentLoginAlert()
                return
            }

            if index == self.currentIndex {
                if index == 0 {
                    if let nav = self.viewControllers[index] as? UINavigationController,
                       let homeVC = nav.viewControllers.first as? HomeViewController {
                        homeVC.resetToToday()
                    }
                } else if index == 1 {
                    if let nav = self.viewControllers[index] as? UINavigationController,
                       let mapVC = nav.viewControllers.first as? MainMapViewController {
                        mapVC.reloadContent()
                    }
                }
            }

            self.switchToViewController(at: index)
        }
        
        viewControllers.forEach { navController in
            navController.delegate = self
            navController.setNavigationBarHidden(false, animated: false)
        }
    }

    override func setLayout() {
        tabBarView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        contentContainerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            contentBottomConstraint = $0.bottom.equalTo(tabBarView.snp.top).constraint
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        switchToViewController(at: currentIndex)
    }
    
    // MARK: - Navigation Control

    private func switchToViewController(at index: Int) {
        contentContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        let selectedNav = viewControllers[index]
        
        contentContainerView.addSubview(selectedNav.view)
        selectedNav.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        tabBarView.setSelectedIndex(index)
        currentIndex = index
        
        updateTabBarVisibility(for: selectedNav.topViewController)
    }
    
    private func updateTabBarVisibility(for viewController: UIViewController?) {
        guard let vc = viewController as? BaseViewController else { return }
        setTabBarHidden(vc.shouldHideTabBar, animated: false)
    }
    
    private func presentLoginAlert() {
        let alert = UIAlertController(
            title: "로그인이 필요한 서비스입니다",
            message: "로그인 하시겠습니까?",
            preferredStyle: .alert
        )

        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigateToLogin()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            self.tabBarView.setSelectedIndex(self.currentIndex)
        }

        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    private func navigateToLogin() {
        let loginVC = LoginViewController()

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            window.replaceRootViewController(loginVC)
        }
    }
    
    public func showDialog(
            title: String,
            message: String,
            cancelButtonTitle: String = "취소하기",
            confirmButtonTitle: String = "확인",
            confirmAction: @escaping () -> Void
        ) {
            let dialogView = EATSSUDialogView()
            
            dialogView.configure(title: title, message: message)
            dialogView.setButtonTitles(cancel: cancelButtonTitle, confirm: confirmButtonTitle)
            
            dialogView.cancelButton.addAction(UIAction { _ in
                dialogView.removeFromSuperview()
            }, for: .touchUpInside)
            
            dialogView.confirmButton.addAction(UIAction { _ in
                confirmAction()
                dialogView.removeFromSuperview()
            }, for: .touchUpInside)
            
            self.view.addSubview(dialogView)
            dialogView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }

    // MARK: - Public Interface

    public func setTab(index: Int) {
        switchToViewController(at: index)
    }
    
    public func getNavController(at index: Int) -> UINavigationController? {
        guard index < viewControllers.count else { return nil }
        return viewControllers[index]
    }
    
    // MARK: - 탭바 가시성 제어
    
    public func setTabBarHidden(_ hidden: Bool, animated: Bool) {
        // 중복 호출 방지
        if tabBarView.isHidden == hidden { return }
        
        print("🎯 TabBar 상태 변경: \(hidden ? "숨김" : "표시")")
        
        // 제약조건 업데이트
        contentBottomConstraint?.deactivate()
        contentContainerView.snp.remakeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            if hidden {
                contentBottomConstraint = $0.bottom.equalToSuperview().constraint
            } else {
                contentBottomConstraint = $0.bottom.equalTo(tabBarView.snp.top).constraint
            }
        }
        
        let animations = {
            self.tabBarView.alpha = hidden ? 0 : 1
            self.view.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: animations) { _ in
                self.tabBarView.isHidden = hidden
            }
        } else {
            animations()
            self.tabBarView.isHidden = hidden
        }
    }
}

// MARK: - UINavigationControllerDelegate

extension CustomTabBarContainerController: UINavigationControllerDelegate {
    
    /// ✅ 네비게이션 전환 시 탭바 가시성 자동 업데이트
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        guard let vc = viewController as? BaseViewController else {
            print("⚠️ BaseViewController가 아닌 VC: \(viewController)")
            return
        }
        
        print("📱 네비게이션 전환: \(type(of: vc)) - shouldHideTabBar: \(vc.shouldHideTabBar)")
        
        // shouldHideTabBar 값에 따라 자동으로 탭바 가시성 조절
        setTabBarHidden(vc.shouldHideTabBar, animated: animated)
    }
}
