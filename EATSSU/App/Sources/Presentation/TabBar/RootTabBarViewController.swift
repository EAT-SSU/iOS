//
//  RootTabBarViewController.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 1/27/25.
//

import UIKit

import EATSSUDesign
import EATSSUKit

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
            in: self
        ) { [weak self] in
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
        // 탭바 아이템 선택 시 햅틱 피드백 제공
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
                // 학과 정보가 입력된 경우 기존 로직 수행
            } else {
                // 학과 정보가 입력되지 않은 경우 모달 시트 표시
                presentDepartmentInfoModal()
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

    /// 학과 정보 입력 여부에 따라 모달 시트를 표시하는 메서드
    private func presentDepartmentInfoModal() {
        let modalVC = DepartmentInfoRequestModalViewController()
        modalVC.modalPresentationStyle = .pageSheet
        modalVC.isModalInPresentation = true

        if let sheet = modalVC.sheetPresentationController {
            sheet.detents = [.medium()] // 화면의 절반 정도 높이
            sheet.prefersGrabberVisible = false
        }

        modalVC.onButtonTapped = { [weak self] in
            self?.dismiss(animated: true) {
                self?.selectedIndex = 2
                self?.handleMyPageTabSelected()
            }
        }

        present(modalVC, animated: true)
    }

    /// 사용자가 학과 정보를 입력했는지 확인 (임시 로직)
    private func userEnteredDepartmentInfo() -> Bool {
        // TODO: 서버에서 사용자의 학과 정보 조회 로직 설계
        false
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
