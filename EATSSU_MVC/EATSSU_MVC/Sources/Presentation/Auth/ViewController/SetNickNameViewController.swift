import UIKit

import Moya

final class SetNickNameViewController: BaseViewController {
    // MARK: - Properties

    var currentKeyboardHeight: CGFloat = 0.0
    private let viewModel = SetNickNameViewModel()

    // MARK: - UI Components

    private let setNickNameView = SetNickNameView()

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        dismissKeyboard()
        setNickNameView.bindViewModel(viewModel)
    }

    override func viewWillAppear(_: Bool) {
        addKeyboardNotifications()
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
        viewModel.setUserNickname(nickname: setNickNameView.inputNickNameTextField.text ?? "") { [weak self] success in
            if success {
                self?.showAlertController(title: "완료", message: "닉네임 설정이 완료되었습니다.", style: .cancel) {
                    if let myPageViewController = self?.navigationController?.viewControllers.first(where: { $0 is MyPageViewController }) {
                        self?.navigationController?.popToViewController(myPageViewController, animated: true)
                    } else {
                        let homeViewController = HomeViewController()
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
                        {
                            keyWindow.replaceRootViewController(UINavigationController(rootViewController: homeViewController))
                        }
                    }
                }
            } else {
                self?.view.showToast(message: "닉네임 설정에 실패했습니다. 다시 시도해주세요.")
            }
        }
    }

    @objc
    private func tappedCheckButton() {
        viewModel.checkNicknameAvailability(nickname: setNickNameView.inputNickNameTextField.text ?? "") { [weak self] isAvailable in
            if isAvailable {
                self?.view.showToast(message: "사용 가능한 닉네임이에요")
            } else {
                self?.view.showToast(message: "이미 사용 중인 닉네임이에요")
            }
        }
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
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            setNickNameView.completeSettingNickNameButton.frame.origin.y += currentKeyboardHeight
            currentKeyboardHeight = 0.0
        }
    }
}
