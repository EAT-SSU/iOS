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
    private let userDepartmentService = UserDepartmentService()

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupTabBar()
    }

    private func setupTabBar() {
        // 기존 탭바를 커스텀 탭바로 교체
        tabBar.removeFromSuperview()
        let estTabBar = ESTabBar()
        setValue(estTabBar, forKey: "tabBar")

        // 각 탭에 해당하는 뷰 컨트롤러 생성 및 네비게이션 컨트롤러 래핑
        let homeVC = HomeViewController()
        let mapVC = MapViewController()
        let mypageVC = MyPageViewController(hasAccessToken: RealmService.shared.isAccessTokenPresent())

        let homeNav = UINavigationController(rootViewController: homeVC)
        let mapNav = UINavigationController(rootViewController: mapVC)
        let mypageNav = UINavigationController(rootViewController: mypageVC)

        homeNav.tabBarItem = UITabBarItem(title: "학식", image: UIImage(systemName: "fork.knife"), tag: 0)
        mapNav.tabBarItem = UITabBarItem(title: "지도", image: UIImage(systemName: "map.fill"), tag: 1)
        mypageNav.tabBarItem = UITabBarItem(title: "마이", image: UIImage(systemName: "person.fill"), tag: 2)

        viewControllers = [homeNav, mapNav, mypageNav]
        tabBar.tintColor = EATSSUDesignAsset.Color.Main.primary.color
        tabBar.backgroundColor = .white
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

            // 비동기적으로 학과 정보 입력 여부 확인
            userEnteredDepartmentInfo { [weak self] isEntered in
                DispatchQueue.main.async {
                    if isEntered {
                        // 학과 정보가 입력된 경우, 기존 로직 실행
                        // 예: 해당 탭의 뷰 컨트롤러로 전환 등 추가 로직
                    } else {
                        self?.presentDepartmentInfoModal()
                    }
                }
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

    /// 학과 정보 입력 여부를 비동기적으로 확인하는 메서드
    private func userEnteredDepartmentInfo(completion: @escaping (Bool) -> Void) {
        userDepartmentService.validateDepartment { result in
            switch result {
            case let .success(isEntered):
                completion(isEntered)
            case .failure:
                completion(false)
            }
        }
    }

    /// 학과 정보 입력이 되어있지 않은 경우 모달 시트를 표시하는 메서드
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

    /// 마이 페이지 탭 선택 시 로그인 여부에 따라 로직을 분기하는 메서드
    private func handleMyPageTabSelected() {
        if RealmService.shared.isAccessTokenPresent() {
            #if DEBUG
                print("MyPageViewController로 이동")
            #endif
        } else {
            presentLoginAlert()
        }
    }

    /// 로그인이 필요한 경우 확인 알림을 표시하는 메서드
    private func presentLoginAlert() {
        AlertControllerHelper.showConfirmOnlyAlert(
            title: "로그인이 필요한 서비스입니다.",
            message: "로그인 하시겠습니까?",
            confirmTitle: "확인",
            in: self
        ) { [weak self] in
            self?.changeIntoLoginVC()
        }
    }

    /// 로그인 뷰 컨트롤러로 전환하는 메서드
    private func changeIntoLoginVC() {
        let loginViewController = LoginViewController()
        WindowManageHelper.replaceWindowViewControllerWith(loginViewController)
    }
}
