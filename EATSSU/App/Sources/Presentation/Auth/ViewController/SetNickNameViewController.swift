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
    private let nicknameProvider = MoyaProvider<UserNicknameRouter>(session: Session(interceptor: AuthInterceptor.shared))

    // MARK: - UI Components
    
    private let setNickNameView = SetNickNameView()
    private func getDepartments(for college: String) -> [String] {
        switch college {
        case "인문대": return ["국어국문학과", "영어영문학과", "철학과"]
        case "자연대": return ["수학과", "물리학과", "화학과"]
        default: return []
        }
    }

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        dismissKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNickNameView.setAccountInfo()
    }

    override func viewWillDisappear(_: Bool) {
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
        let nickname = setNickNameView.inputNickNameTextField.text ?? ""
        let department = setNickNameView.departmentDropDownView.getSelectedTitle() ?? ""

        setUserNickname(nickname) { [weak self] nickOK in
            guard nickOK, let self else { return }

            self.setUserDepartment(department) { deptOK in
                guard deptOK else { return }
                self.showCompletionAlert()
            }
        }
    }

    @objc
    private func tappedCheckButton() {
        checkNickname(nickname: setNickNameView.inputNickNameTextField.text ?? "")
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
        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            setNickNameView.completeSettingNickNameButton.frame.origin.y += currentKeyboardHeight
            currentKeyboardHeight = 0.0
        }
    }
    
    private func navigateToLogin() {
        let loginVC = LoginViewController()
        loginVC.toastMessage = "시스템 오류로 다시 로그인해주세요"
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                keyWindow.replaceRootViewController(UINavigationController(rootViewController: loginVC))
            }
        }
    }
}

// MARK: - Network

extension SetNickNameViewController {
    private func setUserNickname(_ nickname: String, completion: @escaping (Bool) -> Void) {
        nicknameProvider.request(.setNickname(nickname: nickname)) { result in
            switch result {
            case .success:
                if let user = UserInfoManager.shared.getCurrentUserInfo() {
                    UserInfoManager.shared.updateNickname(for: user, nickname: nickname)
                }
                completion(true)
            case .failure:
                RealmService.shared.resetDB()
                self.navigateToLogin()
                completion(false)
            }
        }
    }

    private func checkNickname(nickname: String) {
        nicknameProvider.request(.checkNickname(nickname: nickname)) { response in
            switch response {
            case let .success(moyaResponse):
                do {
                    let responseData = try moyaResponse.map(BaseResponse<Bool>.self)
                    guard let data = responseData.result else { return }
                    
                    if data {
                        self.view.showToast(message: "사용 가능한 닉네임이에요")
                        self.setNickNameView.setNicknameChecked(true)
                        self.setNickNameView.nicknameValidationMessageLabel.text = NicknameTextFieldResultType.nicknameTextFieldValid.hintMessage
                        self.setNickNameView.nicknameValidationMessageLabel.textColor = NicknameTextFieldResultType.nicknameTextFieldValid.textColor
                    } else {
                        self.view.showToast(message: "이미 사용 중인 닉네임이에요")
                        self.setNickNameView.completeSettingNickNameButton.isEnabled = data
                        self.setNickNameView.nicknameValidationMessageLabel.text = NicknameTextFieldResultType.nicknameTextFieldDuplicated.hintMessage
                        self.setNickNameView.nicknameValidationMessageLabel.textColor = NicknameTextFieldResultType.nicknameTextFieldDuplicated.textColor
                    }
                    
                } catch let err {
                    print(err.localizedDescription)
                    
                    RealmService.shared.resetDB()
                    self.navigateToLogin()
                }
            case let .failure(err):
                print(err.localizedDescription)
                
                RealmService.shared.resetDB()
                self.navigateToLogin()
            }
        }
    }
    
    private func setUserDepartment(_ department: String, completion: @escaping (Bool) -> Void) {
        nicknameProvider.request(.setDepartment(department: department)) { result in
            switch result {
            case .success:
                print("학과 등록 성공: \(department)")
                completion(true)
            case .failure(let error):
                print("학과 등록 실패: \(error.localizedDescription)")
                RealmService.shared.resetDB()
                self.navigateToLogin()
                completion(false)
            }
        }
    }
    
    private func showCompletionAlert() {
        self.showAlertController(title: "완료",
                                 message: "정보 수정이 완료되었습니다.",
                                 style: .cancel) {
            if let myPageVC = self.navigationController?
                .viewControllers
                .first(where: { $0 is MyPageViewController }) {
                self.navigationController?.popToViewController(myPageVC, animated: true)
            } else {
                let homeVC = HomeViewController()
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                    keyWindow.replaceRootViewController(
                        UINavigationController(rootViewController: homeVC)
                    )
                }
            }
        }
    }
}
