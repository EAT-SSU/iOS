//
//  RootTabBarViewController.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 1/27/25.
//

import UIKit

class RootTabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
    }

    private func setupTabBar() {
        let homeViewController = HomeViewController()
        let searchViewController = MapsViewController()
        let settingsViewController = MyPageViewController()

        // 각 뷰컨트롤러를 네비게이션 컨트롤러로 래핑
        let homeNav = UINavigationController(rootViewController: homeViewController)
        let searchNav = UINavigationController(rootViewController: searchViewController)
        let settingsNav = UINavigationController(rootViewController: settingsViewController)

        // 탭바 아이템 설정
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
        searchNav.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "map.fill"), tag: 1)
        settingsNav.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape.fill"), tag: 2)

        // 탭바 컨트롤러에 뷰컨트롤러 추가
        viewControllers = [homeNav, searchNav, settingsNav]

        // 탭바 스타일 설정 (선택적)
        tabBar.tintColor = .systemBlue
        tabBar.backgroundColor = .white
    }
}
