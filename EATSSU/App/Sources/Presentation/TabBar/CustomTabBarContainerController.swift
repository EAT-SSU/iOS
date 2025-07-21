//
//  CustomTabBarContainerController.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 6/21/25.
//

import UIKit

final class CustomTabBarContainerController: BaseViewController {

    // MARK: - Properties

    private let tabBarView = CustomTabBarView()
    private let viewControllers: [UIViewController] = [
        UINavigationController(rootViewController: HomeViewController()),
        UINavigationController(rootViewController: MainMapViewController()),
        UINavigationController(rootViewController: MyPageViewController())
    ]
    private var currentIndex = 0

    // MARK: - View Setup

    override func configureUI() {
        view.addSubview(tabBarView)

        tabBarView.buttonTapped = { [weak self] index in
            guard let self = self else { return }

            // 마이페이지는 로그인 필요
            if index == 2, RealmService.shared.isAccessTokenPresent() == false {
                self.presentLoginAlert()
                return
            }

            // 같은 탭 다시 클릭 시 reloadContent
            if index == self.currentIndex {
                if let nav = self.viewControllers[index] as? UINavigationController,
                   let mapVC = nav.viewControllers.first as? MainMapViewController {
                    mapVC.reloadContent()
                }
            }

            self.switchToViewController(at: index)
        }
    }

    override func setLayout() {
        tabBarView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.snp.bottom)
            $0.height.equalTo(74)
        }
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        switchToViewController(at: currentIndex)
    }

    // MARK: - Navigation Control

    /// 탭 전환 처리
    private func switchToViewController(at index: Int) {
        let selectedVC = viewControllers[index]

        // 기존 자식 뷰컨 정리
        children.forEach { child in
            child.view.removeFromSuperview()
            child.removeFromParent()
        }

        // 새로운 뷰컨 추가
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

    /// 로그인 필요 시 알림창 표시
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

    /// 로그인 화면으로 전환
    private func navigateToLogin() {
        let loginVC = LoginViewController()

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            window.replaceRootViewController(loginVC)
        }
    }

    // MARK: - Public Interface

    /// 외부에서 탭 전환 요청 시 사용
    public func setTab(index: Int) {
        switchToViewController(at: index)
    }

    /// 특정 탭의 네비게이션 컨트롤러 반환
    public func getNavController(at index: Int) -> UINavigationController? {
        guard index < viewControllers.count else { return nil }
        return viewControllers[index] as? UINavigationController
    }
}
