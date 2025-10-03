//
//  ReviewTabBarContainerController.swift
//  EATSSU
//
//  Created by 한금준 on 10/3/25.
//

import UIKit

// Review 전용 탭바 컨테이너
final class ReviewTabBarContainerController: BaseViewController {

//    private let tabBarView = CustomTabBarView() // 혹은 ReviewTabBarView 따로 만들기
    
    private let tabBarView: MainButton = {
            let button = MainButton()
            button.title = "리뷰 작성하기"
            return button
        }()
    
    let reviewVC = ReviewViewController()
    
    private lazy var viewControllers: [UIViewController] = [
            UINavigationController(rootViewController: reviewVC),
//            UINavigationController(rootViewController: myReviewsVC),
//            UINavigationController(rootViewController: reportVC)
        ]
    
    private var currentIndex = 0

    override func configureUI() {
        view.addSubview(tabBarView)

//        tabBarView.buttonTapped = { [weak self] index in
//            self?.switchToViewController(at: index)
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            var parentVC = self.parent
            while parentVC != nil {
                if let customTabBar = parentVC as? CustomTabBarContainerController {
                    customTabBar.setTabBarHidden(false, animated: false)
                    break
                }
                parentVC = parentVC?.parent
            }
        }
    }
    
    override func setButtonEvent() {
        tabBarView.addTarget(self, action: #selector(handleAddReviewButtonTap), for: .touchUpInside)
    }
    
    @objc private func handleAddReviewButtonTap() {
        let reviewVC = SetRateViewController()
        
        if let nav = viewControllers[currentIndex] as? UINavigationController {
            nav.pushViewController(reviewVC, animated: true)
        }
    }
    
    override func setLayout() {
        tabBarView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(80)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        switchToViewController(at: currentIndex)
    }

    private func switchToViewController(at index: Int) {
        let selectedVC = viewControllers[index]
        children.forEach {
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }
        addChild(selectedVC)
        view.insertSubview(selectedVC.view, belowSubview: tabBarView)
        selectedVC.view.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(tabBarView.snp.top)
        }
        selectedVC.didMove(toParent: self)
//        tabBarView.setSelectedIndex(index)
        currentIndex = index
    }
}
