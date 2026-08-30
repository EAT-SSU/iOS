//
//  LikeViewController.swift
//  EATSSU
//
//  Created by 황상환 on 8/30/26.
//

import UIKit

import SnapKit

import EATSSUDesign

/// 찜 탭 루트. 상단 언더라인 탭(메뉴 찜 / 제휴 찜)과 가로 스와이프 페이지로 구성
final class LikeViewController: BaseViewController {

    // MARK: - Properties

    private(set) var currentTab: LikeTab = .partnership

    /// 지도의 플로팅 하트로 진입한 경우 true. 뒤로가기가 지도 탭 복귀로 동작한다
    private var showsBackToMap = false

    private let menuViewController = MenuLikePlaceholderViewController()
    private let partnershipViewController = LikedPartnershipViewController()
    private var pages: [UIViewController] { [menuViewController, partnershipViewController] }

    // MARK: - UI Components

    private let tabView = UnderlineTabView(titles: LikeTab.allCases.map { $0.title })
    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )

    // MARK: - View Setup

    override func configureUI() {
        view.backgroundColor = .white

        addChild(pageViewController)
        view.addSubviews(tabView, pageViewController.view)
        pageViewController.didMove(toParent: self)
        pageViewController.dataSource = self
        pageViewController.delegate = self
    }

    override func setLayout() {
        tabView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
        pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(tabView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    override func setButtonEvent() {
        tabView.onSelect = { [weak self] index in
            guard let tab = LikeTab(rawValue: index) else { return }
            self?.showPage(for: tab, animated: true)
        }
    }

    override func setCustomNavigationBar() {
        super.setCustomNavigationBar()
        navigationItem.title = TextLiteral.Like.title
        updateBackButton()
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        showPage(for: currentTab, animated: false)
        tabView.select(index: currentTab.rawValue, animated: false)
    }

    // MARK: - Public

    /// 탭 전환 전에 호출해 표시할 하위 탭과 뒤로가기 동작을 정한다
    func prepare(tab: LikeTab, showsBackToMap: Bool) {
        self.showsBackToMap = showsBackToMap
        currentTab = tab
        if isViewLoaded {
            showPage(for: tab, animated: false)
            tabView.select(index: tab.rawValue, animated: false)
            updateBackButton()
        }
    }

    /// 탭바에서 찜 탭을 다시 눌렀을 때 현재 페이지 갱신
    func reloadContent() {
        if currentTab == .partnership {
            partnershipViewController.reload()
        }
    }

    // MARK: - Private

    private func showPage(for tab: LikeTab, animated: Bool) {
        let target = pages[tab.rawValue]
        let direction: UIPageViewController.NavigationDirection = tab.rawValue >= currentTab.rawValue ? .forward : .reverse
        currentTab = tab
        pageViewController.setViewControllers([target], direction: direction, animated: animated)
    }

    private func updateBackButton() {
        guard showsBackToMap else {
            navigationItem.leftBarButtonItem = nil
            return
        }
        let backItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(didTapBackToMap)
        )
        backItem.tintColor = .gray500
        navigationItem.leftBarButtonItem = backItem
    }

    @objc private func didTapBackToMap() {
        showsBackToMap = false
        updateBackButton()
        (tabBarController as? CustomTabBarContainerController)?.returnToMapTab()
    }
}

// MARK: - UIPageViewControllerDataSource / Delegate

extension LikeViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
        return pages[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed,
              let visible = pageViewController.viewControllers?.first,
              let index = pages.firstIndex(of: visible),
              let tab = LikeTab(rawValue: index) else { return }
        currentTab = tab
        tabView.select(index: index, animated: true)
    }
}
