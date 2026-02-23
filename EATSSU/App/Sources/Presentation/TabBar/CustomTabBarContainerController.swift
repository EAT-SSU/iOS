//
//  CustomTabBarContainerController.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 6/21/25.
//

import UIKit

import EATSSUDesign

import SnapKit

final class CustomTabBarContainerController: UITabBarController {

    // MARK: - Types

    private enum Tab: Int {
        case home = 0
        case map = 1
        case coffee = 2
        case myPage = 3
    }

    // MARK: - Properties

    private lazy var tabViewControllers: [UINavigationController] = [
        UINavigationController(rootViewController: HomeViewController()),
        UINavigationController(rootViewController: MainMapViewController()),
        UINavigationController(rootViewController: CoffeeWebViewController()),
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

        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .white
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    private func setupViewControllers() {
        let tabConfigurations: [(title: String, normal: UIImage, selected: UIImage, size: CGSize)] = [
            (TextLiteral.TabBar.meal, EATSSUDesignAsset.Images.tabMeal.image, EATSSUDesignAsset.Images.tabMealSelected.image, CGSize(width: 23, height: 23)),
            (TextLiteral.TabBar.map, EATSSUDesignAsset.Images.tabMap.image, EATSSUDesignAsset.Images.tabMapSelected.image, CGSize(width: 23, height: 23)),
            (TextLiteral.TabBar.coffee, EATSSUDesignAsset.Images.coffee.image, EATSSUDesignAsset.Images.coffeeSelected.image, CGSize(width: 23, height: 23)),
            (TextLiteral.TabBar.my, EATSSUDesignAsset.Images.tabMypage.image, EATSSUDesignAsset.Images.tabMypageSelected.image, CGSize(width: 44, height: 23))
        ]

        tabViewControllers.enumerated().forEach { index, navController in
            let config = tabConfigurations[index]
            let normalImage = config.normal.resized(to: config.size).withRenderingMode(.alwaysOriginal)
            let selectedImage = config.selected.resized(to: config.size).withRenderingMode(.alwaysOriginal)

            navController.tabBarItem = UITabBarItem(
                title: config.title,
                image: normalImage,
                selectedImage: selectedImage
            )
        }

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
        cancelButtonTitle: String = TextLiteral.Common.cancelDark,
        confirmButtonTitle: String = TextLiteral.Common.confirm,
        cancelAction: (() -> Void)? = nil,
        confirmAction: @escaping () -> Void
    ) {
        let dialogView = EATSSUDialogView()

        dialogView.configure(title: title, message: message)
        dialogView.setButtonTitles(cancel: cancelButtonTitle, confirm: confirmButtonTitle)

        dialogView.cancelButton.addAction(UIAction { _ in
            cancelAction?()
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
    
    
    /// 탭바를 숨기거나 표시합니다.
    /// - Parameters:
    ///   - hidden: true면 숨김, false면 표시
    ///   - animated: 애니메이션 여부
    public override func setTabBarHidden(_ hidden: Bool, animated: Bool) {
        // 이미 원하는 상태라면 종료
        if tabBar.isHidden == hidden, tabBar.alpha == (hidden ? 0 : 1) {
            return
        }

        let tabBarHeight = tabBar.frame.height
        let targetTransform: CGAffineTransform = hidden
            ? CGAffineTransform(translationX: 0, y: tabBarHeight)
            : .identity
        let targetAlpha: CGFloat = hidden ? 0 : 1

        // 표시로 전환 시에는 먼저 isHidden을 풀어야 애니메이션이 보임
        if !hidden { tabBar.isHidden = false }

        let animations = {
            self.tabBar.transform = targetTransform
            self.tabBar.alpha = targetAlpha
        }

        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: animations) { _ in
                // 숨김 전환 완료 후 isHidden 처리
                if hidden { self.tabBar.isHidden = true }
            }
        } else {
            animations()
            tabBar.isHidden = hidden
        }
    }
    
    // MARK: - Private Helpers
    
    /// 로그인 필요 시 알림창 표시
    private func presentLoginAlert() {
        let alert = UIAlertController(
            title: TextLiteral.Common.needLogin,
            message: TextLiteral.Common.askLogin,
            preferredStyle: .alert
        )

        let confirmAction = UIAlertAction(title: TextLiteral.Common.confirm, style: .default) { [weak self] _ in
            self?.navigateToLogin()
        }
        let cancelAction = UIAlertAction(title: TextLiteral.Common.cancel, style: .cancel)

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
              let index = tabViewControllers.firstIndex(of: navController),
              let selectedTab = Tab(rawValue: index) else {
            return true
        }

        // 마이페이지, 지도, 커피는 로그인 필요
        if (selectedTab == .coffee || selectedTab == .map || selectedTab == .myPage), RealmService.shared.isAccessTokenPresent() == false {
            presentLoginAlert()
            return false
        }

        // 지도 탭 클릭 시 Firebase 이벤트 호출 (로그인된 상태에서만)
        if selectedTab == .map {
            MapAnalyticsManager.shared.logClickMap()
        }

        // 같은 탭 다시 클릭 시 처리
        if index == selectedIndex {
            switch selectedTab {
            case .home:
                // 학식 탭: 오늘이 아니면 오늘로 이동
                if let homeVC = navController.viewControllers.first as? HomeViewController {
                    homeVC.resetToToday()
                }
            case .coffee:
                break
            case .map:
                // 지도 탭: 콘텐츠 리로드
                if let mapVC = navController.viewControllers.first as? MainMapViewController {
                    mapVC.reloadContent()
                }
            case .myPage:
                break
            }
        }

        return true
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
