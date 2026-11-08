//
//  HomeViewController.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/08/08.
//

import UIKit
import Combine

import Moya
import SnapKit

import EATSSUDesign

final class HomeViewController: BaseViewController {
    // MARK: - Properties

    private var currentDate = Date() {
        didSet {
            #if DEBUG
                print("Changed Date: \(currentDate)")
            #endif
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    private var hasCheckedPromotionPopup = false
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: EATSSUDesignAsset.Images.mainLogoSmall.image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    /// 알림함 진입 버튼. 안 읽은 알림이 있으면 점이 있는 아이콘을 보여준다
    /// 디자인: 24×24 아이콘, 우측 24, 로고와 세로 중앙 정렬. 터치 영역은 44
    private let notificationButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(EATSSUDesignAsset.Images.icBell.image, for: .normal)
        button.accessibilityLabel = TextLiteral.Notification.inboxTitle
        button.accessibilityIdentifier = "home.notificationButton"
        return button
    }()

    private let tabmanController = CustomTimeTabController()
    private let homeCalendarView = HomeCalendarView()

    /// 안 읽은 알림 조회 요청마다 증가. 연달아 보낸 요청의 응답 순서가 뒤바뀌어도 마지막 요청만 배지에 반영한다
    private var unreadBadgeRequestID = 0

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setupDelegates()
        configureUI()
        setLayout()
        registerTabman()
        addUnreadBadgeObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logFirebaseEvent()
        
        logScreenView(screenID: FirebaseScreenID.Home.home1)
        // presentPromotionPopupIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        addNewDayObserver()
        
        self.tabBarController?.tabBar.isHidden = false
        // 알림함은 로그인한 사용자만 쓸 수 있어 비로그인이면 아이콘을 숨긴다
        notificationButton.isHidden = !TokenStore.hasAccessToken
        refreshUnreadBadge()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
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

    // MARK: - UI Configuration

    override func configureUI() {
        view.addSubview(logoImageView)
        view.addSubview(notificationButton)
        view.addSubview(homeCalendarView)
    }

    override func setLayout() {
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalToSuperview()
            make.height.equalTo(28)
        }

        notificationButton.snp.makeConstraints { make in
            make.centerY.equalTo(logoImageView)
            // 44 터치 영역 안에 24 아이콘이 가운데 오므로 우측 여백 24 = 14 + 10
            make.trailing.equalToSuperview().inset(14)
            make.size.equalTo(44)
        }

        homeCalendarView.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(13)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }
    }

    override func setButtonEvent() {
        notificationButton.addTarget(self, action: #selector(didTapNotificationButton), for: .touchUpInside)
    }

    // MARK: - Notification Inbox

    @objc private func didTapNotificationButton() {
        navigationController?.pushViewController(NotificationInboxViewController(), animated: true)
    }

    /// 안 읽은 알림 여부를 다시 확인하는 시점: 화면 진입, 앱 활성화, 사용 중 푸시 도착, 알림 읽음 처리
    private func addUnreadBadgeObservers() {
        let names: [Notification.Name] = [
            UIApplication.didBecomeActiveNotification,
            .didReceivePushNotification,
            .didUpdateNotificationReadState
        ]
        names.forEach {
            NotificationCenter.default.addObserver(self, selector: #selector(refreshUnreadBadge), name: $0, object: nil)
        }
    }

    @objc private func refreshUnreadBadge() {
        // 푸시 도착(`willPresent`) 알림은 메인 큐 호출이 보장되지 않아 메인으로 옮긴다
        guard Thread.isMainThread else {
            DispatchQueue.main.async { self.refreshUnreadBadge() }
            return
        }
        guard TokenStore.hasAccessToken else { return }
        unreadBadgeRequestID += 1
        let requestID = unreadBadgeRequestID
        NotificationInboxService.fetchHasUnread { [weak self] result in
            guard let self, requestID == self.unreadBadgeRequestID, case .success(let hasUnread) = result else { return }
            let image = hasUnread ? EATSSUDesignAsset.Images.icBellUnread.image : EATSSUDesignAsset.Images.icBell.image
            self.notificationButton.setImage(image, for: .normal)
        }
    }

    // MARK: - Tabman Setup

    private func registerTabman() {
        addChild(tabmanController)
        view.addSubview(tabmanController.view)
        tabmanController.view.snp.makeConstraints { make in
            make.top.equalTo(homeCalendarView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        tabmanController.didMove(toParent: self)
    }
    
    // MARK: - Public Functions

    /// 리뷰 작성 후 데이터 새로고침
    func refreshAfterReview() {
        tabmanController.reloadData(for: currentDate)
    }
    
    /// 하단 탭바에서 학식 탭 클릭 시 오늘 날짜로 초기화
    func resetToToday() {
        let today = Date()
        
        // 이미 오늘 날짜면 아무것도 안 함
        if Calendar.current.isDate(currentDate, inSameDayAs: today) {
            return
        }
        // 오늘이 아니면 날짜 업데이트
        currentDate = today
        homeCalendarView.setSelected(date: today)
        tabmanController.updateDate(to: today)
    }
    
    /// 학식 알림으로 진입: 해당 날짜와 시간대(없으면 현재 시각 기준 시간대)로 이동
    func show(date: Date, mealTimeIndex: Int?) {
        currentDate = date
        homeCalendarView.setSelected(date: date)
        tabmanController.updateDate(to: date)
        tabmanController.select(index: mealTimeIndex ?? tabmanController.currentTimeIndex)
    }

    // MARK: - Private Functions

    private func presentPromotionPopupIfNeeded() {
        guard !hasCheckedPromotionPopup else { return }
        hasCheckedPromotionPopup = true
        
        guard HomePromotionPopupDisplayData.shouldShow else { return }
        guard presentedViewController == nil else { return }
        
        let popupVC = PromotionPopupViewController()
        popupVC.modalPresentationStyle = .overFullScreen
        popupVC.modalTransitionStyle = .crossDissolve
        present(popupVC, animated: true)
    }

    // MARK: - Firebase

    private func logFirebaseEvent() {
        FirebaseRemoteConfig.shared.fetchRestaurantInfo()
    }

    // MARK: - Delegates

    private func setupDelegates() {
        homeCalendarView.delegate = tabmanController
        tabmanController.datePublisher
            .assign(to: \.currentDate, on: self)
            .store(in: &cancellables)
    }
    
    @objc private func handleNewDayNotification(_ notification: Notification) {
        // 백그라운드에서 돌아와 새로운 날로 판단될 때, 오늘 날짜로 갱신
        DispatchQueue.main.async {
            let today = Date()
            self.currentDate = today
            // 달력뷰에 오늘 날짜가 선택되도록 호출
            self.homeCalendarView.setSelected(date: today)
        }
    }
}

// MARK: - Calendar Selection Delegate

extension HomeViewController: CalendarSeletionDelegate {
    func didSelectCalendar(date: Date) {
        currentDate = date
    }
}
