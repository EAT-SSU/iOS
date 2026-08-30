//
//  PromotionPopupViewController.swift
//  EATSSU
//
//  Created by jeongminji on 3/16/26.
//

import UIKit

import SnapKit

/// 홈 화면 진입 시 노출되는 프로모션 팝업
final class PromotionPopupViewController: BaseViewController {
    
    // MARK: - UI Components
    
    private let popupView = PromotionPopupView()
    
    // MARK: - Properties
    
    /// 잇슈 인스타그램 바로가기 버튼 클릭 시 이동
    private let nabatdaePostURL: URL = {
        guard let url = URL(string: "https://www.instagram.com/p/DVu1n6SEs5b/?igsh=Y2lmOXV0OTAzeHZy") else {
            fatalError("Invalid URL string for nabatdaePostURL")
        }
        return url
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    
    // MARK: - UI Configuration
    
    override func configureUI() {
        view.addSubview(popupView)
    }
    
    override func setLayout() {
        popupView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func setButtonEvent() {
        popupView.instagramLinkButton.addTarget(
            self,
            action: #selector(didTapInstagramLinkButton),
            for: .touchUpInside
        )
        
        popupView.neverShowAgainButton.addTarget(
            self,
            action: #selector(didTapNeverShowAgainButton),
            for: .touchUpInside
        )
        
        popupView.closeButton.addTarget(
            self,
            action: #selector(didTapCloseButton),
            for: .touchUpInside
        )
        
        let contentTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapPopupContent)
        )
        contentTapGesture.delegate = self
        contentTapGesture.cancelsTouchesInView = false
        popupView.containerView.addGestureRecognizer(contentTapGesture)
    }
    
    // MARK: - Private Functions
    
    /// 잇슈 인스타그램 바로가기 버튼 클릭 -> 나받돼 게시물로 이동
    @objc
    private func didTapInstagramLinkButton() {
        AnalyticsService.logEvent("popup_event", parameters: [
            "popup_name": "plz_not_me",
            "popup_action": "go_insta"
        ])
        UIApplication.shared.open(nabatdaePostURL)
    }
    
    /// 팝업의 그 외 영역 클릭 -> 닫기 (이동하던 '나만아니면돼' 탭은 제거됨)
    @objc
    private func didTapPopupContent() {
        AnalyticsService.logEvent("popup_event", parameters: [
            "popup_name": "plz_not_me",
            "popup_action": "click_popup_image"
        ])
        dismiss(animated: true)
    }
    
    /// 다시 보지 않기 -> 평생 안 뜸
    @objc
    private func didTapNeverShowAgainButton() {
        AnalyticsService.logEvent("popup_event", parameters: [
            "popup_name": "plz_not_me",
            "popup_action": "not_show_again"
        ])
        HomePromotionPopupDisplayData.hideForever()
        dismiss(animated: true)
    }
    
    @objc
    private func didTapCloseButton() {
        AnalyticsService.logEvent("popup_event", parameters: [
            "popup_name": "plz_not_me",
            "popup_action": "close"
        ])
        dismiss(animated: true)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension PromotionPopupViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: popupView.containerView)
        
        if popupView.instagramLinkButton.frame.contains(location) {
            return false
        }
        
        return true
    }
}
