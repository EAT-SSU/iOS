//
//  ProvisionView.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 11/19/23.
//

// Swift Module
import UIKit
import WebKit

enum AgreementType {
    case termsOfService
    case privacyPolicy
}

final class ProvisionView: BaseUIView {
    // MARK: - UI Components

    private let webView: WKWebView!

    // MARK: - Initiazlier

    init(agreementType: AgreementType) {
        webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        super.init(frame: .zero)

        connectWebLink(agreementType: agreementType)
    }

    // MARK: - Functions

    override func configureUI() {
        addSubview(webView)
    }

    override func setLayout() {
        webView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(10)
        }
    }

    private func connectWebLink(agreementType: AgreementType) {
        switch agreementType {
        case .termsOfService:
            if let termsOfServiceURL = URL(string: "https://github.com/EAT-SSU/Docs/wiki/EAT%E2%80%90SSU-%EC%84%9C%EB%B9%84%EC%8A%A4-%EC%9D%B4%EC%9A%A9%EC%95%BD%EA%B4%80") {
                let request = URLRequest(url: termsOfServiceURL)
                webView.load(request)
            } else {
                /*
                 해야 할 일
                 - 안정성을 높이기 위한 코드 작성
                 */
            }
        case .privacyPolicy:
            if let privacyPolicyURL = URL(string: "https://github.com/EAT-SSU/Docs/wiki/EAT%E2%80%90SSU-%EA%B0%9C%EC%9D%B8%EC%A0%95%EB%B3%B4%EC%B2%98%EB%A6%AC%EB%B0%A9%EC%B9%A8") {
                let request = URLRequest(url: privacyPolicyURL)
                webView.load(request)
            } else {
                /*
                 해야 할 일
                 - 안정성을 높이기 위한 코드 작성
                 */
            }
        }
    }
}
