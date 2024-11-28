//
//  LoginPromptViewController.swift
//  EATSSU
//
//  Created by 최지우 on 11/26/24.
//

import UIKit

final class LoginPromptViewController: BaseViewController {
    
    // MARK: - UI Components
    
    private let loginPromptView = ios16LoginPromptView()
    
    // MARK: - Functions

    override func configureUI() {
        view.addSubview(loginPromptView)
    }
    
    override func setLayout() {
        loginPromptView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
