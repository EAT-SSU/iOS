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
        // 학식 탭
        let homeVC = HomeViewController()
        let homeItem = UITabBarItem(title: "학식", image: UIImage(systemName: "fork.knife"), tag: 0)
        homeItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
        homeItem.imageInsets = UIEdgeInsets(top: -2, left: 0, bottom: 2, right: 0)
        homeVC.tabBarItem = homeItem

        // 지도 탭
        let mapVC = UINavigationController(rootViewController: HomeViewController())
        let mapItem = UITabBarItem(title: "지도", image: UIImage(systemName: "map.fill"), tag: 1)
        mapItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
        mapItem.imageInsets = UIEdgeInsets(top: -2, left: 0, bottom: 2, right: 0)
        mapVC.tabBarItem = mapItem

        // 마이 탭
        let myVC = UINavigationController(rootViewController: MyPageViewController())
        let myItem = UITabBarItem(title: "마이", image: UIImage(systemName: "person.fill"), tag: 2)
        myItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
        myItem.imageInsets = UIEdgeInsets(top: -2, left: 0, bottom: 2, right: 0)
        myVC.tabBarItem = myItem

        // 탭 배열 등록
        viewControllers = [homeVC, mapVC, myVC]
    }

    
    private func setupTabBarStyle() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        // 배경 흰색
        appearance.backgroundColor = .white

        // 분리선 제거
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()

        // 선택 상태 색상 (선택됨/비선택)
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.selected.iconColor = UIColor.systemTeal
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemTeal]
        itemAppearance.normal.iconColor = UIColor.gray
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        appearance.stackedLayoutAppearance = itemAppearance

        // 탭바 자체 스타일
        tabBar.layer.cornerRadius = 20
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabBar.layer.masksToBounds = false

        // 그림자 효과
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.06
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -6)
        tabBar.layer.shadowRadius = 12

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }

}

