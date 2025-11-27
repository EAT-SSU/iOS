//
//  CustomTimeTabController.swift
//  EATSSU
//
//  Created by 황상환 on 3/30/25.
//

import UIKit
import Combine

import SnapKit

import EATSSUDesign

final class CustomTimeTabController: BaseViewController {
    // MARK: - Properties

    private let tabTitles = ["아침", "점심", "저녁"]
    private var selectedIndex: Int = 0 {
        didSet {
            updateTabSelection(animated: true)
            setPage(index: selectedIndex, direction: selectedIndex > oldValue ? .forward : .reverse)
        }
    }
    var todayDate: Date = .init()

    private var isProgrammaticScroll = false
    private var cancellables = Set<AnyCancellable>()
    private let dateSubject = PassthroughSubject<Date, Never>()
    
    var datePublisher: AnyPublisher<Date, Never> {
        dateSubject.eraseToAnyPublisher()
    }

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

    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = EATSSUDesignAsset.Color.GrayScale.gray100.color
        setupDatePipeline()
    }
    
    @objc private func handleNewDayNotification(_ notification: Notification) {
        // 백그라운드에서 돌아와 새로운 날로 판단될 때, 오늘 날짜로 갱신
        DispatchQueue.main.async {
            let today = Date()
            self.todayDate = today
            // 당일에 해당하는 데이터 불러오기
            self.dateFetchData(for: today)
            
            // 해당 시간대별로 인덱스 이동 후 시간대 변경
            let initialIndex = self.getInitialTabIndex()
            self.selectedIndex = initialIndex
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dateFetchData(for: todayDate)
        addNewDayObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNewDayObserver()
    }
    
    private func addNewDayObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewDayNotification(_:)),
            name: .didEnterNewDay,
            object: nil
        )
    }
    
    private func removeNewDayObserver() {
        NotificationCenter.default.removeObserver(self, name: .didEnterNewDay, object: nil)
    }

    override func configureUI() {
        view.backgroundColor = EATSSUDesignAsset.Color.GrayScale.gray100.color

        view.addSubview(tabShadowWrapperView)
        tabShadowWrapperView.backgroundColor = EATSSUDesignAsset.Color.GrayScale.gray100.color

        tabShadowWrapperView.addSubview(tabContainerView)
        tabContainerView.backgroundColor = .white
        tabContainerView.layer.cornerRadius = 30
        tabContainerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tabContainerView.layer.masksToBounds = false
        tabContainerView.layer.shadowColor = UIColor.gray700Basic.cgColor
        tabContainerView.layer.shadowOpacity = 0.6
        tabContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabContainerView.layer.shadowRadius = 7
        tabContainerView.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 43, width: UIScreen.main.bounds.width, height: 2)).cgPath

        tabContainerView.addSubview(tabStackView)
        tabStackView.axis = .horizontal
        tabStackView.distribution = .fillEqually
        tabStackView.alignment = .fill

        for (index, title) in tabTitles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.setTitleColor(EATSSUDesignAsset.Color.GrayScale.gray700.color, for: .normal)
            button.titleLabel?.font = UIFont.subtitle2
            button.tag = index
            button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
            tabStackView.addArrangedSubview(button)
            tabButtons.append(button)
        }

        tabContainerView.addSubview(indicatorView)
        indicatorView.backgroundColor = EATSSUDesignAsset.Color.Main.primary.color
        indicatorView.layer.cornerRadius = 1
        indicatorView.layer.masksToBounds = true
    }

    override func setLayout() {
        tabShadowWrapperView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }

        tabContainerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(52)
        }

        tabStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 0, bottom: 8, right: 0))
        }

        indicatorView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.height.equalTo(3)
            $0.width.equalTo(50)
            $0.centerX.equalTo(tabButtons.first!.snp.centerX)
        }

        setupPageViewController()
    }
    
    func dateFetchData(for date: Date) {
        dateSubject.send(date)
    }

    private func setupPageViewController() {
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(tabShadowWrapperView.snp.bottom).inset(-10)
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

        let initialIndex = getInitialTabIndex()
        pageViewController.setViewControllers([viewControllers[initialIndex]], direction: .forward, animated: false)
        self.selectedIndex = initialIndex
    }

    private func setPage(index: Int, direction: UIPageViewController.NavigationDirection) {
        let vc = viewControllers[index]
        pageViewController.setViewControllers([vc], direction: direction, animated: true) { [weak self] _ in
            self?.isProgrammaticScroll = false
        }
    }

    @objc private func tabButtonTapped(_ sender: UIButton) {
        guard selectedIndex != sender.tag else { return }
        //  firebase - select_mealtime 이벤트 호출
        let selectedMealTime = tabTitles[sender.tag]
        HomeAnalyticsManager.shared.logSelectMealTime(mealTime: selectedMealTime)
        isProgrammaticScroll = true
        selectedIndex = sender.tag
    }

    private func updateTabSelection(animated: Bool) {
        for (index, button) in tabButtons.enumerated() {
            let isSelected = index == selectedIndex
            button.setTitleColor(isSelected ? EATSSUDesignAsset.Color.Main.primary.color : EATSSUDesignAsset.Color.GrayScale.gray700.color, for: .normal)
        }

        let tabWidth = view.frame.width / CGFloat(tabTitles.count)
        let x = tabWidth * CGFloat(selectedIndex)
        let transform = CGAffineTransform(translationX: x, y: 0)

        if animated {
            UIView.animate(withDuration: 0.25) {
                self.indicatorView.transform = transform
            }
        } else {
            self.indicatorView.transform = transform
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
    
    // 날짜 변경 파이프라인 설정
    private func setupDatePipeline() {
        dateSubject
            .debounce(for: .milliseconds(150), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] date in
                self?.performDateUpdate(date)
            }
            .store(in: &cancellables)
    }
    
    private func performDateUpdate(_ date: Date) {
        morningVC.fetchData(date: date, time: "MORNING")
        lunchVC.fetchData(date: date, time: "LUNCH")
        dinnerVC.fetchData(date: date, time: "DINNER")
    }

    // MARK: - External API

    func updateDate(to date: Date) {
       todayDate = date
       dateSubject.send(date)
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
        // firebase - select_mealtime 이벤트 호출
        let selectedMealTime = tabTitles[index]
        HomeAnalyticsManager.shared.logSelectMealTime(mealTime: selectedMealTime)
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
        // firebase - select_day 이벤트 호출
        HomeAnalyticsManager.shared.logSelectDay(date: date)
        let currentMealTime = self.tabTitles[self.selectedIndex]
        // firebase - select_mealtime 이벤트 호출
        HomeAnalyticsManager.shared.logSelectMealTime(mealTime: currentMealTime)
        updateDate(to: date)
    }
}
