//
//  NotificationInboxViewController.swift
//  EATSSU
//
//  Created by 황상환 on 11/7/26.
//

import UIKit

import SnapKit

import EATSSUDesign

/// 알림함: 최근 7일 찜 메뉴 알림 목록 · 모두 읽음 · 알림을 누르면 해당 날짜·시간대의 학식 화면으로 이동
///
/// 삭제는 없고 7일이 지나면 서버가 지운다. 이미 읽은 알림을 눌러도 이동한다
final class NotificationInboxViewController: BaseViewController {

    // MARK: - Constants

    /// 디자인: 상단 "모두 읽음" 영역 높이 40, 좌우 24, 하단 안내 문구는 안전 영역 위 22
    private enum Layout {
        static let headerHeight: CGFloat = 40
        static let horizontalInset: CGFloat = 24
        static let noticeBottomInset: CGFloat = 22
        static let estimatedRowHeight: CGFloat = 84
    }

    override var shouldHideTabBar: Bool { true }

    // MARK: - Properties

    private var notifications: [NotificationItemDTO] = []
    private var hasLoaded = false

    private var hasUnread: Bool {
        notifications.contains { !$0.isRead }
    }

    // MARK: - UI Components

    private let readAllButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyView = EmptyStateView()
    private let noticeLabel = UILabel()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        loadNotifications()
    }

    // MARK: - View Setup

    override func configureUI() {
        view.backgroundColor = .white

        readAllButton.setTitle(TextLiteral.Notification.readAll, for: .normal)
        readAllButton.titleLabel?.font = .body2
        readAllButton.setTitleColor(.gray600, for: .normal)
        readAllButton.setTitleColor(.gray300, for: .disabled)
        readAllButton.isEnabled = false

        tableView.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Layout.estimatedRowHeight
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false

        emptyView.configure(title: TextLiteral.Notification.emptyTitle, subtitle: TextLiteral.Notification.emptySubtitle)
        emptyView.isHidden = true

        noticeLabel.text = TextLiteral.Notification.retentionNotice
        noticeLabel.font = .caption2
        noticeLabel.textColor = .gray500
        noticeLabel.textAlignment = .center
        noticeLabel.isHidden = true

        view.addSubviews(readAllButton, tableView, emptyView, noticeLabel)
    }

    override func setLayout() {
        readAllButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.height.equalTo(Layout.headerHeight)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(readAllButton.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        emptyView.snp.makeConstraints {
            $0.edges.equalTo(tableView)
        }
        noticeLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(Layout.noticeBottomInset)
        }
    }

    override func setButtonEvent() {
        readAllButton.addTarget(self, action: #selector(didTapReadAll), for: .touchUpInside)
    }

    override func setCustomNavigationBar() {
        super.setCustomNavigationBar()
        navigationItem.title = TextLiteral.Notification.inboxTitle
    }

    // MARK: - Data

    private func loadNotifications() {
        NotificationInboxService.fetchNotifications { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let notifications):
                self.notifications = notifications
                self.hasLoaded = true
            case .failure(let error):
                print("알림 목록 조회 실패: \(error.localizedDescription)")
                self.showToast(message: TextLiteral.Notification.loadFailed, type: .danger)
            }
            self.render()
        }
    }

    private func render() {
        let isEmpty = hasLoaded && notifications.isEmpty
        emptyView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        noticeLabel.isHidden = notifications.isEmpty
        // 디자인: 알림이 없으면 "모두 읽음"도 보이지 않는다
        readAllButton.isHidden = notifications.isEmpty
        readAllButton.isEnabled = hasUnread
        // 마지막 행이 하단 안내 문구에 가리지 않게 한다
        let noticeHeight = noticeLabel.intrinsicContentSize.height + Layout.noticeBottomInset * 2
        tableView.contentInset.bottom = notifications.isEmpty ? 0 : noticeHeight
        tableView.reloadData()
    }

    // MARK: - Actions

    @objc private func didTapReadAll() {
        let previous = notifications
        notifications = notifications.map { Self.marked($0, isRead: true) }
        render()
        NotificationInboxService.markAllRead { [weak self] result in
            guard let self, case .failure(let error) = result else { return }
            print("알림 모두 읽음 실패: \(error.localizedDescription)")
            self.notifications = previous
            self.render()
        }
    }

    /// 알림을 누르면 읽음 처리하고 학식 탭의 해당 날짜·시간대로 이동한다. 읽음 처리 실패는 이동을 막지 않는다
    private func open(_ notification: NotificationItemDTO, at indexPath: IndexPath) {
        if !notification.isRead {
            notifications[indexPath.row] = Self.marked(notification, isRead: true)
            render()
            NotificationInboxService.markRead(notificationId: notification.notificationId)
        }
        // 푸시 data와 같은 형태로 만들어 푸시 탭과 같은 이동 규칙을 쓴다
        var userInfo: [AnyHashable: Any] = ["type": notification.type, "date": notification.date]
        if let timePart = notification.timePart {
            userInfo["timePart"] = timePart
        }
        guard let route = PushRoute(userInfo: userInfo),
              let tabBarController = tabBarController as? CustomTabBarContainerController else { return }
        tabBarController.showHomeMenu(on: route.date, mealTime: route.mealTime)
    }

    private static func marked(_ notification: NotificationItemDTO, isRead: Bool) -> NotificationItemDTO {
        NotificationItemDTO(
            notificationId: notification.notificationId,
            type: notification.type,
            title: notification.title,
            body: notification.body,
            date: notification.date,
            timePart: notification.timePart,
            isRead: isRead,
            createdAt: notification.createdAt
        )
    }

    private func timeText(for notification: NotificationItemDTO) -> String? {
        let locale = Locale(identifier: AppLanguageManager.shared.currentLanguage.rawValue)
        switch NotificationTimeDisplay.make(createdAt: notification.createdAt, locale: locale) {
        case .justNow:
            return TextLiteral.Notification.justNow
        case .hoursAgo(let hours):
            return TextLiteral.Notification.hoursAgo(hours)
        case .date(let text):
            return text
        case nil:
            return nil
        }
    }
}

// MARK: - UITableViewDataSource

extension NotificationInboxViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationCell.identifier, for: indexPath) as? NotificationCell else {
            return UITableViewCell()
        }
        let notification = notifications[indexPath.row]
        cell.configure(
            title: notification.title,
            body: notification.body,
            time: timeText(for: notification),
            isRead: notification.isRead
        )
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NotificationInboxViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        open(notifications[indexPath.row], at: indexPath)
    }
}
