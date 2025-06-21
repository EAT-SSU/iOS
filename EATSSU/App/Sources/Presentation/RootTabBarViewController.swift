//
//  RootTabBarViewController.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 6/20/25.
//

import UIKit

final class RootTabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupTabBarStyle()
        view.backgroundColor = .white
    }

    private func setupTabBar() {
        let homeVC = HomeViewController()
        let mapVC = UINavigationController(rootViewController: HomeViewController())
        let myVC = UINavigationController(rootViewController: MyPageViewController())

        homeVC.tabBarItem = UITabBarItem(title: "학식", image: UIImage(systemName: "fork.knife"), tag: 0)
        mapVC.tabBarItem = UITabBarItem(title: "지도", image: UIImage(systemName: "map.fill"), tag: 1)
        myVC.tabBarItem = UITabBarItem(title: "마이", image: UIImage(systemName: "person.fill"), tag: 2)

        viewControllers = [homeVC, mapVC, myVC]
    }
    
    private func setupTabBarStyle() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white

        tabBar.layer.cornerRadius = 20
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabBar.layer.masksToBounds = false

        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.1
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBar.layer.shadowRadius = 10

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }

}

