//
//  UserWithdrawViewController.swift
//  EAT-SSU
//
//  Created by 박윤빈 on 6/3/24.
//

import UIKit

import Moya
import Realm
import SnapKit
import Then

final class UserWithdrawViewController: BaseViewController {
    // MARK: - Properties

    private var nickName = String()
    var currentKeyboardHeight: CGFloat = 0.0
    private let myProvider = MoyaProvider<MyRouter>(plugins: [MoyaLoggingPlugin()])

    // MARK: - UI Components

    private lazy var userWithdrawView = UserWithdrawView(nickName: nickName)

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        dismissKeyboard()
    }

    override func viewWillAppear(_: Bool) {
        addKeyboardNotifications()
    }

    override func viewWillDisappear(_: Bool) {
        removeKeyboardNotifications()
    }

    // MARK: - Initializer

    init(nickName: String) {
        self.nickName = nickName

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions

    override func configureUI() {
        view.addSubviews(userWithdrawView)
    }

    override func setLayout() {
        userWithdrawView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func setCustomNavigationBar() {
        super.setCustomNavigationBar()
        navigationItem.title = "탈퇴하기"
    }

    override func setButtonEvent() {
        userWithdrawView.completeSignOutButton.addTarget(self, action: #selector(completeNickNameButtonTapped), for: .touchUpInside)
    }

    @objc
    func completeNickNameButtonTapped() {
        deleteUser()
    }

    // MARK: - 디바이스 키보드 감지

    private func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }

    @objc
    private func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let updateKeyboardHeight = keyboardSize.height
            let difference = updateKeyboardHeight - currentKeyboardHeight

            userWithdrawView.completeSignOutButton.frame.origin.y -= difference
            currentKeyboardHeight = updateKeyboardHeight
        }
    }

    @objc
    private func keyboardWillHide(_ notification: Notification) {
        // TODO: keyboardSize 변수는 사용하지 않아서 _ 로 대체했지만, 해당 로직이 왜 필요한 지 연구
        if let _ = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            userWithdrawView.completeSignOutButton.frame.origin.y += currentKeyboardHeight
            currentKeyboardHeight = 0.0
        }
    }
}

// MARK: - Network

extension UserWithdrawViewController {
    private func deleteUser() {
        myProvider.request(.signOut) { response in
            switch response {
            case let .success(moyaResponse):
                do {
                    let responseData = try moyaResponse.map(BaseResponse<Bool>.self)
                    if responseData.result {
                        RealmService.shared.resetDB()
                        let loginViewController = LoginViewController()
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
                        {
                            keyWindow.replaceRootViewController(UINavigationController(rootViewController: loginViewController))
                        }
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
