//
//  ProvisionViewController.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 11/19/23.
//

// Swift Module
import UIKit
import WebKit

// External Module
import SnapKit

final class ProvisionViewController: BaseViewController {
    // MARK: - Properties

    var navigationTitle = TextLiteral.MyPage.defaultTerms

    // MARK: - UI Components

    let provisionView: ProvisionView!

    // MARK: - Life Cycles

    // MARK: - Initalizer

    init(agreementType: AgreementType) {
        provisionView = ProvisionView(agreementType: agreementType)

        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Functions

    override func setCustomNavigationBar() {
        super.setCustomNavigationBar()
        navigationItem.title = navigationTitle
    }

    override func configureUI() {
        view.addSubview(provisionView)
    }

    override func setLayout() {
        provisionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
