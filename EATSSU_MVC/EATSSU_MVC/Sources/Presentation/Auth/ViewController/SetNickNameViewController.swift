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
		firstly {
			model.setUserNickname(nickname: setNickNameView.inputNickNameTextField.text ?? "")
		}.done {
			// FIXME: 문자열 리소스 관리 파일로 전환
			self.showAlertController(title: "완료", message: "닉네임 설정이 완료되었습니다.", style: .cancel) {
				if let myPageViewController = self.navigationController?.viewControllers.first(where: { $0 is MyPageViewController }) {
					self.navigationController?.popToViewController(myPageViewController, animated: true)
				} else {
					let homeViewController = HomeViewController()
					if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
					   let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
					{
						keyWindow.replaceRootViewController(UINavigationController(rootViewController: homeViewController))
					}
				}
			}
		}.catch { err in
			print(err.localizedDescription)
		}
	}
    
	@objc
	private func tappedCheckButton() {
		firstly {
			model.checkNickname(nickname: setNickNameView.inputNickNameTextField.text ?? "")
		}.done { isSuccess in
			if isSuccess {
				// FIXME: 문자열 리소스 관리파일로 전환
				self.view.showToast(message: "사용 가능한 닉네임이에요")
				self.setNickNameView.completeSettingNickNameButton.isEnabled = isSuccess
				self.setNickNameView.nicknameValidationMessageLabel.text = NicknameTextFieldResultType.nicknameTextFieldValid.hintMessage
				self.setNickNameView.nicknameValidationMessageLabel.textColor = NicknameTextFieldResultType.nicknameTextFieldValid.textColor
			} else {
				// FIXME: 문자열 리소스 관리파일로 전환
				self.view.showToast(message: "이미 사용 중인 닉네임이에요")
				self.setNickNameView.completeSettingNickNameButton.isEnabled = isSuccess
				self.setNickNameView.nicknameValidationMessageLabel.text = NicknameTextFieldResultType.nicknameTextFieldDuplicated.hintMessage
				self.setNickNameView.nicknameValidationMessageLabel.textColor = NicknameTextFieldResultType.nicknameTextFieldDuplicated.textColor
			}
		}.catch { err in
			print(err.localizedDescription)
		}
	}
    
	// MARK: - 키보드 감지
    
	func addKeyboardNotifications() {
		NotificationCenter
			.default
			.addObserver(self,
			             selector: #selector(keyboardWillShow(_:)),
			             name: UIResponder.keyboardWillShowNotification,
			             object: nil)
		NotificationCenter
			.default
			.addObserver(self, selector: #selector(keyboardWillHide(_:)),
			             name: UIResponder.keyboardWillHideNotification,
			             object: nil)
	}

	func removeKeyboardNotifications() {
		NotificationCenter
			.default
			.removeObserver(self,
			                name: UIResponder.keyboardWillShowNotification,
			                object: nil)
		NotificationCenter
			.default
			.removeObserver(self,
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

	@objc
	func keyboardWillHide(_ notification: Notification) {
		// FIXME: 의미를 알 수 없는 경고가 발생
		if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
			setNickNameView.completeSettingNickNameButton.frame.origin.y += currentKeyboardHeight
			currentKeyboardHeight = 0.0
		}
	}
}
