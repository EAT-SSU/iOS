//
//  CustomTabBarContainerController.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 6/21/25.
//

import UIKit

final class CustomTabBarContainerController: UIViewController {

    private let tabBarView = CustomTabBarView()
    private let viewControllers: [UIViewController] = [
        HomeViewController(),
        HomeViewController(),
        MyPageViewController()
    ]
    private var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTabBar()
        switchToViewController(at: currentIndex)
    }

    private func setupTabBar() {
        view.addSubview(tabBarView)
        tabBarView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.snp.bottom)
            $0.height.equalTo(74)
        }

        tabBarView.buttonTapped = { [weak self] index in
            self?.switchToViewController(at: index)
        }
    }


    private func switchToViewController(at index: Int) {
        let selectedVC = viewControllers[index]

        // remove previous
        children.forEach { child in
            child.view.removeFromSuperview()
            child.removeFromParent()
        }

        addChild(selectedVC)
        view.insertSubview(selectedVC.view, belowSubview: tabBarView)
        selectedVC.view.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(tabBarView.snp.top)
        }
        selectedVC.didMove(toParent: self)

        tabBarView.setSelectedIndex(index)
        currentIndex = index
    }
}
