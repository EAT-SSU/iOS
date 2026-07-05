//
//  LanguageSettingViewController.swift
//  EATSSU
//
//  Created by jeongminji on 5/3/26.
//

import UIKit

import SnapKit
import EATSSUDesign

final class LanguageSettingViewController: BaseViewController {
    override var shouldHideTabBar: Bool { true }

    // MARK: - Properties

    /// 언어 설정 화면에서 실제로 언어가 변경되었는지 여부
    /// - true이면 뒤로가기 시 앱 전체 화면을 새 언어 기준으로 다시 구성
    private var didChangeLanguage = false

    /// 버튼 뒤로가기와 swipe back에서 root 재구성이 중복 호출되는 것을 방지
    private var isResettingRootViewController = false

    private var selectedLanguage: AppLanguage {
        return AppLanguageManager.shared.currentLanguage
    }

    // MARK: - UI Components

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.rowHeight = 48
        tableView.backgroundColor = .white
        return tableView
    }()

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        setTableViewDelegate()
        registerTableViewCells()
        setInteractivePopGesture()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard didChangeLanguage,
              isMovingFromParent,
              !isResettingRootViewController else {
            return
        }

        resetRootAfterLanguageChangeIfNeeded()
    }

    // MARK: - Functions

    override func setCustomNavigationBar() {
        super.setCustomNavigationBar()

        navigationItem.title = TextLiteral.MyPage.languageSetting

        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonDidTap)
        )

        backButton.tintColor = .gray500
        navigationItem.leftBarButtonItem = backButton
    }

    override func configureUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
    }

    override func setLayout() {
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func setTableViewDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func registerTableViewCells() {
        tableView.register(
            RadioSelectionTableViewCell.self,
            forCellReuseIdentifier: RadioSelectionTableViewCell.identifier
        )
    }

    private func setInteractivePopGesture() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    @objc
    private func backButtonDidTap() {
        if didChangeLanguage {
            resetRootAfterLanguageChangeIfNeeded()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    private func changeLanguage(to language: AppLanguage) {
        guard language != AppLanguageManager.shared.currentLanguage else {
            return
        }

        AppLanguageManager.shared.changeLanguage(to: language)
        didChangeLanguage = true

        AnalyticsService.logEvent("change_language", parameters: ["language": language.rawValue])

        updateLocalizedTexts()
    }

    private func updateLocalizedTexts() {
        navigationItem.title = TextLiteral.MyPage.languageSetting
        tableView.reloadData()
    }

    private func resetRootAfterLanguageChangeIfNeeded() {
        guard !isResettingRootViewController else { return }

        isResettingRootViewController = true
        resetRootViewController()
    }

    private func resetRootViewController() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return
        }

        let customTabBarController = CustomTabBarContainerController()

        _ = customTabBarController.view
        customTabBarController.setTab(index: 3)

        keyWindow.replaceRootViewController(customTabBarController)
    }
}

// MARK: - UITableViewDataSource

extension LanguageSettingViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return AppLanguage.allCases.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: RadioSelectionTableViewCell.identifier,
            for: indexPath
        ) as? RadioSelectionTableViewCell else {
            return UITableViewCell()
        }

        let language = AppLanguage.allCases[indexPath.row]

        cell.configure(
            title: language.title,
            isSelected: language == selectedLanguage
        )

        return cell
    }
}

// MARK: - UITableViewDelegate

extension LanguageSettingViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        let language = AppLanguage.allCases[indexPath.row]

        changeLanguage(to: language)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension LanguageSettingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}
