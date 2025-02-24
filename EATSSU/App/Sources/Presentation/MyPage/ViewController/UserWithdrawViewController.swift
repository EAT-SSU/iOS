//
//  UserWithdrawViewController.swift
//  EAT-SSU
//
//  Created by 박윤빈 on 6/3/24.
//

import UIKit

import EATSSUKit

import AlertKit
import Moya
import Realm
import SnapKit
import Then

final class UserWithdrawViewController: BaseViewController {
    // MARK: - Properties

    private var nickName = String()
    private var currentKeyboardHeight: CGFloat = 0.0
    private let myProvider = MoyaProvider<MyRouter>(plugins: [ESMoyaLoggingPlugin()])

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

    override func setESNavigationBar() {
        super.setESNavigationBar()
        navigationItem.title = "탈퇴하기"
    }

    override func setButtonEvent() {
        userWithdrawView.completeSignOutButton.addTarget(
            self, action: #selector(signoutButtonTapped), for: .touchUpInside
        )
    }

    @objc
    func signoutButtonTapped() {
        deleteUser()
    }

    // MARK: - Detect device keyboard

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
                        WindowManageHelper.replaceWindowViewControllerWith(loginViewController)
                        AlertKitAPI.present(
                            title: "탈퇴가 완료되었습니다", icon: .error, style: .iOS17AppleMusic, haptic: .success
                        )
                    }
                } catch let err {
                    #if DEBUG
                        print(err.localizedDescription)
                    #endif
                    AlertKitAPI.present(
                        title: "문제가 발생했습니다", subtitle: "다시 시도하세요", icon: .error, style: .iOS17AppleMusic, haptic: .success
                    )
                }
            case let .failure(err):
                #if DEBUG
                    print(err.localizedDescription)
                #endif
                AlertKitAPI.present(
                    title: "문제가 발생했습니다", subtitle: "다시 시도하세요", icon: .error, style: .iOS17AppleMusic, haptic: .success
                )
            }
        }
    }
}
