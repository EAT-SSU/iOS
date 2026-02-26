//
//  CoffeeWebViewController.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 2/23/26.
//

import UIKit
import WebKit

import EATSSUDesign

import SnapKit

final class CoffeeWebViewController: BaseViewController {

    // MARK: - UI Components

    private let webView = WKWebView()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "xmark")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold))
        button.setImage(image, for: .normal)
        button.tintColor = .gray700
        button.backgroundColor = .white
        button.layer.cornerRadius = 18
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        return button
    }()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.scrollView.contentInsetAdjustmentBehavior = .never
        loadWebPage()
    }

    override func configureUI() {
        view.addSubview(webView)
        view.addSubview(closeButton)
    }

    override func setLayout() {
        webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(36)
        }
    }

    override func setButtonEvent() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }

    // MARK: - Private

    @objc private func closeTapped() {
        let dialogView = EATSSUDialogView()
        dialogView.configure(
            title: "나가시겠어요?",
            message: "지금 나가면 진행 상황이\n저장되지 않습니다."
        )
        dialogView.setButtonTitles(cancel: "나가기", confirm: "계속하기")
        dialogView.frame = view.bounds
        dialogView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(dialogView)

        dialogView.cancelButton.addAction(UIAction { [weak self] _ in
            dialogView.removeFromSuperview()
            self?.dismiss(animated: true)
        }, for: .touchUpInside)

        dialogView.confirmButton.addAction(UIAction { _ in
            dialogView.removeFromSuperview()
        }, for: .touchUpInside)
    }

    private func loadWebPage() {
        guard let url = URL(string: "https://eatssu-coffee.figma.site/") else { return }
        webView.load(URLRequest(url: url))
    }
}
