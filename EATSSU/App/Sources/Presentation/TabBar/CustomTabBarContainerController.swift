//
//  CustomTabBarContainerController.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 6/21/25.
//

import UIKit

import EATSSUDesign

final class CustomTabBarContainerController: UITabBarController {

    // MARK: - Properties
    
    private var tabViewControllers: [UINavigationController] = [
        UINavigationController(rootViewController: HomeViewController()),
        UINavigationController(rootViewController: MainMapViewController()),
        UINavigationController(rootViewController: MyPageViewController())
    ]
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
        setupViewControllers()
        delegate = self
    }
    
    // MARK: - Setup
    
    private func setupTabBar() {
        tabBar.tintColor = EATSSUDesignAsset.Color.Main.primary.color
        tabBar.unselectedItemTintColor = .gray500
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    private func setupViewControllers() {
        // Home Tab
        let homeNav = tabViewControllers[0]
        let mealImage = EATSSUDesignAsset.Images.tabMeal.image
            .resized(to: CGSize(width: 23, height: 23))
            .withRenderingMode(.alwaysOriginal)
        let mealSelectedImage = EATSSUDesignAsset.Images.tabMealSelected.image
            .resized(to: CGSize(width: 23, height: 23))
            .withRenderingMode(.alwaysOriginal)
        
        homeNav.tabBarItem = UITabBarItem(
            title: "학식",
            image: mealImage,
            selectedImage: mealSelectedImage
        )
        
        // Map Tab
        let mapNav = tabViewControllers[1]
        let mapImage = EATSSUDesignAsset.Images.tabMap.image
            .resized(to: CGSize(width: 23, height: 23))
            .withRenderingMode(.alwaysOriginal)
        let mapSelectedImage = EATSSUDesignAsset.Images.tabMapSelected.image
            .resized(to: CGSize(width: 23, height: 23))
            .withRenderingMode(.alwaysOriginal)
        
        mapNav.tabBarItem = UITabBarItem(
            title: "지도",
            image: mapImage,
            selectedImage: mapSelectedImage
        )
        
        // MyPage Tab
        let myPageNav = tabViewControllers[2]
        let mypageImage = EATSSUDesignAsset.Images.tabMypage.image
            .resized(to: CGSize(width: 44, height: 23))
            .withRenderingMode(.alwaysOriginal)
        let mypageSelectedImage = EATSSUDesignAsset.Images.tabMypageSelected.image
            .resized(to: CGSize(width: 44, height: 23))
            .withRenderingMode(.alwaysOriginal)
        
        myPageNav.tabBarItem = UITabBarItem(
            title: "마이",
            image: mypageImage,
            selectedImage: mypageSelectedImage
        )
        
        // 폰트 설정
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: EATSSUDesignFontFamily.Pretendard.regular.font(size: 11),
            .foregroundColor: UIColor.gray500
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: EATSSUDesignFontFamily.Pretendard.bold.font(size: 11),
            .foregroundColor: EATSSUDesignAsset.Color.Main.primary.color
        ]
        
        tabViewControllers.forEach { nav in
            nav.tabBarItem.setTitleTextAttributes(normalAttributes, for: .normal)
            nav.tabBarItem.setTitleTextAttributes(selectedAttributes, for: .selected)
        }
        
        self.viewControllers = tabViewControllers
    }
    
    // MARK: - Public Interface
    
    /// 외부에서 탭 전환 요청 시 사용
    public func setTab(index: Int) {
        guard index < tabViewControllers.count else { return }
        selectedIndex = index
    }
    
    /// 특정 인덱스의 네비게이션 컨트롤러를 반환
    public func getNavController(at index: Int) -> UINavigationController? {
        guard index < tabViewControllers.count else { return nil }
        return tabViewControllers[index]
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
    
    // MARK: - Private Helpers
    
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
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)

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
}

// MARK: - UITabBarControllerDelegate

extension CustomTabBarContainerController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let navController = viewController as? UINavigationController,
              let index = tabViewControllers.firstIndex(of: navController) else {
            return true
        }
        
        // 지도 탭 클릭 시 Firebase 이벤트 호출
        if index == 1 {
            MapAnalyticsManager.shared.logClickMap()
        }
        
        // 마이페이지와 지도는 로그인 필요
        if (index == 1 || index == 2), RealmService.shared.isAccessTokenPresent() == false {
            presentLoginAlert()
            return false
        }
        
        // 같은 탭 다시 클릭 시 처리
        if index == selectedIndex {
            if index == 0 {
                // 학식 탭: 오늘이 아니면 오늘로 이동
                if let homeVC = navController.viewControllers.first as? HomeViewController {
                    homeVC.resetToToday()
                }
            } else if index == 1 {
                // 지도 탭: 콘텐츠 리로드
                if let mapVC = navController.viewControllers.first as? MainMapViewController {
                    mapVC.reloadContent()
                }
            }
        }
        
        return true
    }
}
