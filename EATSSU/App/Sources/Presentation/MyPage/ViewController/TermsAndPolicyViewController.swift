//
//  TermsAndPolicyViewController.swift
//  EATSSU
//
//  Created by jeongminji on 5/3/26.
//

import UIKit

import SnapKit

final class TermsAndPolicyViewController: BaseViewController {
    override var shouldHideTabBar: Bool { true }
    // MARK: - Properties
    
    enum TermsAndPolicyType: CaseIterable {
        case termsOfUse
        case privacyTermsOfUse

        var title: String {
            switch self {
            case .termsOfUse:
                return TextLiteral.MyPage.termsOfUse

            case .privacyTermsOfUse:
                return TextLiteral.MyPage.privacyTermsOfUse
            }
        }
    }

    private let termsAndPolicyItems = TermsAndPolicyType.allCases

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

        navigationItem.title = TextLiteral.MyPage.termsAndPolicy
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
            MyPageTableDefaultCell.self,
            forCellReuseIdentifier: MyPageTableDefaultCell.identifier
        )
    }
    
    private func pushProvisionViewController(with item: TermsAndPolicyType) {
        let provisionViewController: ProvisionViewController

        switch item {
        case .termsOfUse:
            AnalyticsService.logEvent("click_mypage_menu", parameters: ["menu": "terms_of_use"])
            provisionViewController = ProvisionViewController(agreementType: .termsOfService)

        case .privacyTermsOfUse:
            AnalyticsService.logEvent("click_mypage_menu", parameters: ["menu": "privacy_policy"])
            provisionViewController = ProvisionViewController(agreementType: .privacyPolicy)
        }

        provisionViewController.navigationTitle = item.title

        navigationController?.pushViewController(
            provisionViewController,
            animated: true
        )
    }
}

// MARK: - UITableViewDataSource
extension TermsAndPolicyViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return termsAndPolicyItems.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MyPageTableDefaultCell.identifier,
            for: indexPath
        ) as? MyPageTableDefaultCell else {
            return UITableViewCell()
        }

        let item = termsAndPolicyItems[indexPath.row]
        cell.configure(title: item.title)

        return cell
    }
}

// MARK: - UITableViewDelegate
extension TermsAndPolicyViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = termsAndPolicyItems[indexPath.row]
        pushProvisionViewController(with: item)
    }
}
