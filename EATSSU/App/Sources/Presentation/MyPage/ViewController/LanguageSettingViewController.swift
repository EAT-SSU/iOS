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

    @objc
    private func backButtonDidTap() {
        if didChangeLanguage {
            resetRootViewController()
            print("루트 새로 변경됨")
        } else {
            navigationController?.popViewController(animated: true)
            print("루트 새로 변경안됨")
        }
    }

    private func changeLanguage(to language: AppLanguage) {
        guard language != AppLanguageManager.shared.currentLanguage else {
            return
        }

        AppLanguageManager.shared.changeLanguage(to: language)
        didChangeLanguage = true

        updateLocalizedTexts()
    }

    private func updateLocalizedTexts() {
        navigationItem.title = TextLiteral.MyPage.languageSetting
        tableView.reloadData()
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
