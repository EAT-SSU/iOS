//
//  CoffeeWebViewController.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 2/23/26.
//

import UIKit
import WebKit

import SnapKit

final class CoffeeWebViewController: BaseViewController {

    // MARK: - UI Components

    private let webView = WKWebView()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
        loadWebPage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func configureUI() {
        view.addSubview(webView)
    }

    override func setLayout() {
        webView.snp.makeConstraints {
            $0.top.equalTo(view.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - Private

    private func loadWebPage() {
        guard let url = URL(string: "https://eatssu-coffee.figma.site/") else { return }
        webView.load(URLRequest(url: url))
    }
}
