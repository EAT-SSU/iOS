//
//  CustomTabBarContainerController.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 6/21/25.
//

import UIKit

final class CustomTabBarContainerController: BaseViewController {

    // MARK: - Properties

    private let contentContainerView = UIView()
    private let tabBarView = CustomTabBarView()
    private let viewControllers: [UIViewController] = [
        UINavigationController(rootViewController: HomeViewController()),
        UINavigationController(rootViewController: MainMapViewController()),
        UINavigationController(rootViewController: MyPageViewController())
    ]
    private var currentIndex = 0

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
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        contentContainerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(tabBarView.snp.top)
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
        contentContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        let selectedVC = viewControllers[index]
        
        contentContainerView.addSubview(selectedVC.view)
        selectedVC.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
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
    
    /// 공용 다이얼로그(팝업)를 표시하는 함수
    public func showDialog(
            title: String,
            message: String,
            cancelButtonTitle: String = "취소하기",
            confirmButtonTitle: String = "확인",
            confirmAction: @escaping () -> Void
        ) {
            let dialogView = EATSSUDialogView()
            
            // 다이얼로그 내용 설정
            dialogView.configure(title: title, message: message)
            dialogView.setButtonTitles(cancel: cancelButtonTitle, confirm: confirmButtonTitle)
            
            // '취소' 버튼 액션: 팝업 닫기
            dialogView.cancelButton.addAction(UIAction { _ in
                dialogView.removeFromSuperview()
            }, for: .touchUpInside)
            
            // '확인' 버튼 액션: 전달받은 클로저 실행 후 팝업 닫기
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
        return viewControllers[index] as? UINavigationController
    }
}
