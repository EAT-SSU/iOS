//
//  SetNickNameViewController.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/04.
//

import UIKit

import Moya
import PromiseKit

final class SetNickNameViewController: BaseViewController {
	// MARK: - Properties
	
	var model = SetNickNameModel()
	var currentKeyboardHeight: CGFloat = 0.0

	// MARK: - UI Components
    
	private let setNickNameView = SetNickNameView()
    
	// MARK: - Life Cycles
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
		dismissKeyboard()
	}
    
	override func viewWillAppear(_ animated: Bool) {
		addKeyboardNotifications()
	}
    
	override func viewWillDisappear(_ animated: Bool) {
		removeKeyboardNotifications()
	}
    
	// MARK: - Functions
    
	override func configureUI() {
		view.addSubviews(setNickNameView)
	}
    
	override func setLayout() {
		setNickNameView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}
    
	override func setCustomNavigationBar() {
		super.setCustomNavigationBar()
		navigationItem.title = TextLiteral.setNickName
	}
    
	override func setButtonEvent() {
		setNickNameView.completeSettingNickNameButton.addTarget(self, action: #selector(tappedCompleteNickNameButton), for: .touchUpInside)
		setNickNameView.nicknameDoubleCheckButton.addTarget(self, action: #selector(tappedCheckButton), for: .touchUpInside)
	}
    
	@objc
	func tappedCompleteNickNameButton() {
		model.setUserNickname(nickname: .setNickNameView.inputNickNameTextField.text ?? "")
	}
    
	@objc
	private func tappedCheckButton() {
		model.checkNickname(nickname: setNickNameView.inputNickNameTextField.text ?? "")
	}
    
	// MARK: - keyboard 감지
    
	func addKeyboardNotifications() {
		NotificationCenter.default.addObserver(self,
		                                       selector: #selector(keyboardWillShow(_:)),
		                                       name: UIResponder.keyboardWillShowNotification,
		                                       object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
		                                       name: UIResponder.keyboardWillHideNotification,
		                                       object: nil)
	}

	func removeKeyboardNotifications() {
		NotificationCenter.default.removeObserver(self,
		                                          name: UIResponder.keyboardWillShowNotification,
		                                          object: nil)
		NotificationCenter.default.removeObserver(self,
		                                          name: UIResponder.keyboardWillHideNotification,
		                                          object: nil)
	}

	@objc
	func keyboardWillShow(_ notification: Notification) {
		if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
			let updateKeyboardHeight = keyboardSize.height
			let difference = updateKeyboardHeight - currentKeyboardHeight
            
			setNickNameView.completeSettingNickNameButton.frame.origin.y -= difference
			currentKeyboardHeight = updateKeyboardHeight
		}
	}

	@objc func keyboardWillHide(_ notification: Notification) {
		// FIXME: 의미를 알 수 없는 경고가 발생
		if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
			setNickNameView.completeSettingNickNameButton.frame.origin.y += currentKeyboardHeight
			currentKeyboardHeight = 0.0
		}
	}
}
