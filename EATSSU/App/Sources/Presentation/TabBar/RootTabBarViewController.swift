//
//  RootTabBarViewController.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 1/27/25.
//

import UIKit

import EATSSUKit
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

    private func presentLoginAlert() {
        ESAlertController.showConfirmOnlyAlert(
            title: "로그인이 필요한 서비스입니다.",
            message: "로그인 하시겠습니까?",
            confirmTitle: "확인",
            in: self) { [weak self] in
            self?.changeIntoLoginVC()
        }
    }

    private func changeIntoLoginVC() {
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
        // 탭바의 아이템을 선택했을 때, 제공하는 햅틱 피드백
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.impactOccurred()

        guard let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController) else { return }

        switch selectedIndex {
        case 0:
            #if DEBUG
                print("홈 탭이 선택되었습니다.")
            #endif
        case 1:
            #if DEBUG
                print("제휴지도 탭이 선택되었습니다.")
            #endif
            
            if userEnteredDepartmentInfo() {
                
            } else {
                
            }
        case 2:
            #if DEBUG
                print("마이페이 탭이 선택되었습니다.")
            #endif
            handleMyPageTabSelected()
        default:
            fatalError("선택될 수 없는 탭이 선택됨.")
        }
    }
    
    /// 사용자가 학과 정보를 입력했는지 확인
    private func userEnteredDepartmentInfo() -> Bool {
        // TODO: 서버에 사용자의 학과 정보를 조회하는 로직 설계
        return false
    }

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
