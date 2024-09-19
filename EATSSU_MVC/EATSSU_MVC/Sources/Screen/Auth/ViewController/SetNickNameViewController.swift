//
//  SetNickNameViewController.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/04.
//

import UIKit

import Moya

final class SetNickNameViewController: BaseViewController {
    
    // MARK: - Properties
    
    var currentKeyboardHeight: CGFloat = 0.0
    private let nicknameProvider = MoyaProvider<UserNicknameRouter>(plugins: [MoyaLoggingPlugin()])

    // MARK: - UI Components
    
    private let setNickNameView = SetNickNameView()
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dismissKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeKeyboardNotifications()
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
        self.setUserNickname(nickname: self.setNickNameView.inputNickNameTextField.text ?? "")
    }
    
    @objc
    private func tappedCheckButton() {
        self.checkNickname(nickname: self.setNickNameView.inputNickNameTextField.text ?? "")
    }
    
    // MARK: - keyboard 감지
    
    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)),
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
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            setNickNameView.completeSettingNickNameButton.frame.origin.y += currentKeyboardHeight
            currentKeyboardHeight = 0.0
        }
    }
}

// MARK: - Network

extension SetNickNameViewController {
    private func setUserNickname(nickname: String) {
        self.nicknameProvider.request(.setNickname(nickname: nickname)) { response in
            switch response {
            case .success(let moyaResponse):
                do {
                    if let currentUserInfo = UserInfoManager.shared.getCurrentUserInfo() {
                        UserInfoManager.shared.updateNickname(for: currentUserInfo, nickname: nickname)
                    }
                    self.showAlertController(title: "완료", message: "닉네임 설정이 완료되었습니다.", style: .cancel) {
                        if let myPageViewController = self.navigationController?.viewControllers.first(where: { $0 is MyPageViewController }) {
                            self.navigationController?.popToViewController(myPageViewController, animated: true)
                        } else {
                            let homeViewController = HomeViewController()
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                              keyWindow.replaceRootViewController(UINavigationController(rootViewController: homeViewController))
                            }
                        }
                    }
                    print(moyaResponse.statusCode)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    private func checkNickname(nickname: String) {
        self.nicknameProvider.request(.checkNickname(nickname: nickname)) { response in
            switch response {
            case .success(let moyaResponse):
                do {
                    let responseData = try moyaResponse.map(BaseResponse<Bool>.self)
                    let isSuccess = responseData.result
                    if isSuccess {
                        self.view.showToast(message: "사용 가능한 닉네임이에요")
                        self.setNickNameView.completeSettingNickNameButton.isEnabled = isSuccess
                        self.setNickNameView.nicknameValidationMessageLabel.text = NicknameTextFieldResultType.nicknameTextFieldValid.hintMessage
                        self.setNickNameView.nicknameValidationMessageLabel.textColor = NicknameTextFieldResultType.nicknameTextFieldValid.textColor
                    } else {
                        self.view.showToast(message: "이미 사용 중인 닉네임이에요")
                        self.setNickNameView.completeSettingNickNameButton.isEnabled = isSuccess
                        self.setNickNameView.nicknameValidationMessageLabel.text = NicknameTextFieldResultType.nicknameTextFieldDuplicated.hintMessage
                        self.setNickNameView.nicknameValidationMessageLabel.textColor = NicknameTextFieldResultType.nicknameTextFieldDuplicated.textColor
                    }
                } catch(let err) {
                    print(err.localizedDescription)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
}
