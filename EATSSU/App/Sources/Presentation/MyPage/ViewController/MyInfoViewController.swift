//
//  MyInfoViewController.swift
//  EATSSU
//
//  Created by Jiwoong CHOI on 01/31/25.
//

import Moya
import UIKit

/// 사용자의 닉네임을 설정 및 검증할 수 있는 화면입니다.
final class MyInfoViewController: BaseViewController {
    // MARK: - Properties

    /// 현재 키보드 높이를 저장하는 변수입니다.
    var currentKeyboardHeight: CGFloat = 0.0

    /// 닉네임 관련 API 요청을 위한 Moya Provider입니다.
    let nicknameProvider = MoyaProvider<UserNicknameRouter>(plugins: [ESMoyaLoggingPlugin()])

    // MARK: - UI Components

    /// 사용자 정보 입력 및 닉네임 설정 UI를 포함하는 뷰입니다.
    let myInfoView = MyInfoView()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardNotifications()
    }

    // MARK: - UI 설정

    override func configureUI() {
        view.addSubviews(myInfoView)
    }

    override func setLayout() {
        myInfoView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func setESNavigationBar() {
        super.setESNavigationBar()
        navigationItem.title = ESTextLiteral.Nickname.setNickName
    }

    override func setButtonEvent() {
        myInfoView.completeSettingNickNameButton.addTarget(self, action: #selector(tappedCompleteNickNameButton), for: .touchUpInside)
        myInfoView.nicknameDoubleCheckButton.addTarget(self, action: #selector(tappedCheckButton), for: .touchUpInside)
    }

    // MARK: - 닉네임 설정 이벤트

    /// "닉네임 설정 완료" 버튼을 눌렀을 때 호출됩니다.
    @objc
    func tappedCompleteNickNameButton() {
        setUserNickname(nickname: myInfoView.inputNickNameTextField.text ?? "")
    }

    /// "중복 확인" 버튼을 눌렀을 때 호출됩니다.
    @objc
    func tappedCheckButton() {
        checkNickname(nickname: myInfoView.inputNickNameTextField.text ?? "")
    }

    // MARK: - 키보드 감지

    /// 키보드 이벤트 감지를 위한 옵저버를 추가합니다.
    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    /// 키보드 이벤트 옵저버를 제거합니다.
    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }

    /// 키보드가 나타날 때 호출됩니다.
    @objc
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let updateKeyboardHeight = keyboardSize.height
            let difference = updateKeyboardHeight - currentKeyboardHeight

            myInfoView.completeSettingNickNameButton.frame.origin.y -= difference
            currentKeyboardHeight = updateKeyboardHeight
        }
    }

    /// 키보드가 사라질 때 호출됩니다.
    @objc
    func keyboardWillHide(_ notification: Notification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            myInfoView.completeSettingNickNameButton.frame.origin.y += currentKeyboardHeight
            currentKeyboardHeight = 0.0
        }
    }
}

// MARK: - 네트워크 요청

extension MyInfoViewController {
    /// 사용자의 닉네임을 서버에 설정하는 API 요청을 보냅니다.
    /// - Parameter nickname: 사용자가 입력한 닉네임
    func setUserNickname(nickname: String) {
        nicknameProvider.request(.setNickname(nickname: nickname)) { response in
            switch response {
            case let .success(moyaResponse):
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
                               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
                            {
                                keyWindow.replaceRootViewController(UINavigationController(rootViewController: homeViewController))
                            }
                        }
                    }
                    print(moyaResponse.statusCode)
                }
            case let .failure(err):
                print(err.localizedDescription)
            }
        }
    }

    /// 사용자가 입력한 닉네임의 중복 여부를 확인하는 API 요청을 보냅니다.
    /// - Parameter nickname: 사용자가 입력한 닉네임
    func checkNickname(nickname: String) {
        nicknameProvider.request(.checkNickname(nickname: nickname)) { response in
            switch response {
            case let .success(moyaResponse):
                do {
                    let responseData = try moyaResponse.map(BaseResponse<Bool>.self)
                    let isSuccess = responseData.result
                    if isSuccess {
                        self.view.showToast(message: "사용 가능한 닉네임이에요")
                        self.myInfoView.completeSettingNickNameButton.isEnabled = true
                        self.myInfoView.nicknameValidationMessageLabel.text = NicknameTextFieldResultType.nicknameTextFieldValid.hintMessage
                        self.myInfoView.nicknameValidationMessageLabel.textColor = NicknameTextFieldResultType.nicknameTextFieldValid.textColor
                    } else {
                        self.view.showToast(message: "이미 사용 중인 닉네임이에요")
                        self.myInfoView.completeSettingNickNameButton.isEnabled = false
                        self.myInfoView.nicknameValidationMessageLabel.text = NicknameTextFieldResultType.nicknameTextFieldDuplicated.hintMessage
                        self.myInfoView.nicknameValidationMessageLabel.textColor = NicknameTextFieldResultType.nicknameTextFieldDuplicated.textColor
                    }
                } catch let err {
                    print(err.localizedDescription)
                }
            case let .failure(err):
                print(err.localizedDescription)
            }
        }
    }
}
