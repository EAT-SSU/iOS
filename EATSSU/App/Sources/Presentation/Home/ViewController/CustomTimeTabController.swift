//
//  CustomTimeTabController.swift
//  EATSSU
//
//  Created by 황상환 on 3/30/25.
//

import UIKit
import EATSSUDesign
import SnapKit

final class CustomTimeTabController: UIViewController {
    // MARK: - Properties

    private let tabTitles = ["아침", "점심", "저녁"]
    private var selectedIndex: Int = 0 {
        didSet {
            updateTabSelection(animated: true)
            setPage(index: selectedIndex, direction: selectedIndex > oldValue ? .forward : .reverse)
        }
    }

    private var isProgrammaticScroll = false

    private lazy var morningVC = HomeRestaurantViewController()
    private lazy var lunchVC = HomeRestaurantViewController()
    private lazy var dinnerVC = HomeRestaurantViewController()
    private lazy var viewControllers: [UIViewController] = [morningVC, lunchVC, dinnerVC]

    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    private var scrollView: UIScrollView?

    // MARK: - UI Components

    private let tabShadowWrapperView = UIView()
    private let tabContainerView = UIView()
    private let tabStackView = UIStackView()
    private var tabButtons: [UIButton] = []
    private let indicatorView = UIView()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPageViewController()
        selectedIndex = getInitialTabIndex()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .white

        // Tab Container Wrapper View (no shadow)
        view.addSubview(tabShadowWrapperView)
        tabShadowWrapperView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(52)
        }
        tabShadowWrapperView.backgroundColor = UIColor(hex: "#efeef6")

        // Tab Container View
        tabShadowWrapperView.addSubview(tabContainerView)
        tabContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
//        tabShadowWrapperView.layer.shadowColor = UIColor.black.cgColor
//        tabShadowWrapperView.layer.shadowOpacity = 0.8
//        tabShadowWrapperView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        tabShadowWrapperView.layer.shadowRadius = 8
//        tabShadowWrapperView.layer.masksToBounds = false

        
        tabContainerView.backgroundColor = .white
        tabContainerView.layer.cornerRadius = 30
        tabContainerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
//        tabContainerView.layer.masksToBounds = true

        // Tab StackView
        tabStackView.axis = .horizontal
        tabStackView.distribution = .fillEqually
        tabStackView.alignment = .fill
        tabContainerView.addSubview(tabStackView)
        tabStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 0, bottom: 8, right: 0))
        }

        // Tab Buttons
        for (index, title) in tabTitles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.setTitleColor(.gray700, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            button.tag = index
            button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
            tabStackView.addArrangedSubview(button)
            tabButtons.append(button)
        }

        // Indicator
        indicatorView.backgroundColor = EATSSUDesignAsset.Color.Main.primary.color
        tabContainerView.addSubview(indicatorView)
        indicatorView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.height.equalTo(2)
            $0.width.equalTo(80)
            $0.centerX.equalTo(tabButtons.first!.snp.centerX)
        }
    }

    private func setupPageViewController() {
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(tabShadowWrapperView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        pageViewController.didMove(toParent: self)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        setPage(index: selectedIndex, direction: .forward)

        if let scroll = pageViewController.view.subviews.compactMap({ $0 as? UIScrollView }).first {
            scroll.delegate = self
            scrollView = scroll
        }
    }

    private func setPage(index: Int, direction: UIPageViewController.NavigationDirection) {
        let vc = viewControllers[index]
        pageViewController.setViewControllers([vc], direction: direction, animated: true) { [weak self] _ in
            self?.isProgrammaticScroll = false
        }
    }

    // MARK: - Actions

    @objc private func tabButtonTapped(_ sender: UIButton) {
        guard selectedIndex != sender.tag else { return }
        isProgrammaticScroll = true
        selectedIndex = sender.tag
    }

    private func updateTabSelection(animated: Bool) {
        for (index, button) in tabButtons.enumerated() {
            let isSelected = index == selectedIndex
            button.setTitleColor(isSelected ? EATSSUDesignAsset.Color.Main.primary.color : .gray700, for: .normal)
        }

        let tabWidth = view.frame.width / CGFloat(tabTitles.count)
        let x = tabWidth * CGFloat(selectedIndex)
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.indicatorView.transform = CGAffineTransform(translationX: x, y: 0)
            }
        } else {
            self.indicatorView.transform = CGAffineTransform(translationX: x, y: 0)
        }
    }

    private func getInitialTabIndex() -> Int {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<10: return 0
        case 10..<16: return 1
        case 16..<24: return 2
        default: return 1
        }
    }

    // MARK: - External API

    func updateDate(to date: Date) {
        morningVC.fetchData(date: date, time: "MORNING")
        lunchVC.fetchData(date: date, time: "LUNCH")
        dinnerVC.fetchData(date: date, time: "DINNER")
    }
}

// MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate

extension CustomTimeTabController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController), index > 0 else { return nil }
        return viewControllers[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController), index < viewControllers.count - 1 else { return nil }
        return viewControllers[index + 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let visibleVC = pageViewController.viewControllers?.first,
              let index = viewControllers.firstIndex(of: visibleVC)
        else { return }
        selectedIndex = index
    }
}

// MARK: - UIScrollViewDelegate

extension CustomTimeTabController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isProgrammaticScroll else { return }

        let offsetX = scrollView.contentOffset.x
        let width = scrollView.frame.width
        let progress = (offsetX - width) / width

        let tabWidth = view.frame.width / CGFloat(tabTitles.count)
        let x = tabWidth * (CGFloat(selectedIndex) + progress)
        indicatorView.transform = CGAffineTransform(translationX: x, y: 0)
    }
}

// MARK: - CalendarSeletionDelegate

extension CustomTimeTabController: CalendarSeletionDelegate {
    func didSelectCalendar(date: Date) {
        updateDate(to: date)
    }
}
