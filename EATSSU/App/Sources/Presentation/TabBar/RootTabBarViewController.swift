//
//  RootTabBarViewController.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 1/27/25.
//

import UIKit

import EATSSUDesign

class RootTabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupTabBar()
    }

    // RootTabBarViewController.swift 수정 내용 (setupTabBar 메서드 내)
    private func setupTabBar() {
        // 탭바 인스턴스를 ESTabBar로 교체
        tabBar.removeFromSuperview()
        let estTabBar = ESTabBar()
        // KVC를 사용하여 탭바 교체, 프레임워크에서 제공하는 탭바를 제거하고 커스텀 탭바를 컨트롤러에 등록
        // forKey 값의 tabBar는 탭바를 변경하기 위한 프레임워크에서 예약된 키값
        setValue(estTabBar, forKey: "tabBar")

        // 기존 코드 유지
        let homeViewController = HomeViewController()
        let searchViewController = MapViewController()
        let mypageViewController = MyPageViewController(hasAccessToken: RealmService.shared.isAccessTokenPresent())

        let homeNav = UINavigationController(rootViewController: homeViewController)
        let mapNav = UINavigationController(rootViewController: searchViewController)
        let mypageNav = UINavigationController(rootViewController: mypageViewController)

        homeNav.tabBarItem = UITabBarItem(title: "학식", image: UIImage(systemName: "fork.knife"), tag: 0)
        mapNav.tabBarItem = UITabBarItem(title: "지도", image: UIImage(systemName: "map.fill"), tag: 1)
        mypageNav.tabBarItem = UITabBarItem(title: "마이", image: UIImage(systemName: "person.fill"), tag: 2)

        viewControllers = [homeNav, mapNav, mypageNav]

        tabBar.tintColor = EATSSUDesignAsset.Color.Main.primary.color
        tabBar.backgroundColor = .white
    }

    // FIXME: EATSSUKit으로 이관하여 재사용성 높이기
    private func presentLoginAlert() {
        let alert = UIAlertController(title: "로그인이 필요한 서비스입니다",
                                      message: "로그인 하시겠습니까?",
                                      preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigateToLogin()
        }
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }

    // FIXME: EATSSUKit으로 이관하여 재사용성 높이기
    private func navigateToLogin() {
        let loginVC = LoginViewController()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let window = sceneDelegate.window
        {
            window.replaceRootViewController(loginVC)
        }
    }
}

// MARK: - UITabBarControllerDelegate

extension RootTabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Create and trigger a haptic feedback generator
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.impactOccurred()

        guard let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController) else { return }

        if selectedIndex == 2 {
            #if DEBUG
                print("마이페이 탭(tag 2)이 선택되었습니다.")
            #endif
            handleMyPageTabSelected()
        }
    }

    // TODO: 로그인 유무를 확인하는 비즈니스 로직이 TabBarController와 MyPageViewController 어디에 있는 것이 더 적합한지 고민
    private func handleMyPageTabSelected() {
        if !RealmService.shared.isAccessTokenPresent() {
            presentLoginAlert()
        } else {
            #if DEBUG
                print("MyPageViewController로 이동")
            #endif
        }
    }
}
