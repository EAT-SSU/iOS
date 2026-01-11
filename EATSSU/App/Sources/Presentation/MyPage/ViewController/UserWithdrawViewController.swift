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
import FirebaseAnalytics

final class UserWithdrawViewController: BaseViewController {
    override var shouldHideTabBar: Bool { true }
    // MARK: - Properties

    private var nickName = String()
    private var buttonBottomConstraint: Constraint?

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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        logScreenView(screenID: FirebaseScreenID.MyPage.mypage4)
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
        
        userWithdrawView.completeSignOutButton.snp.remakeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(52)
            buttonBottomConstraint = $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(26).constraint
        }
    }

    override func setCustomNavigationBar() {
        super.setCustomNavigationBar()
        navigationItem.title = TextLiteral.MyPage.withdraw
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
            let keyboardHeight = keyboardSize.height
            
            UIView.animate(withDuration: 0.3) {
                self.buttonBottomConstraint?.update(inset: keyboardHeight + 16)
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc
    private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.buttonBottomConstraint?.update(inset: 26)
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Network

extension UserWithdrawViewController {
    private func deleteUser() {
        NetworkService.shared.request(
            MyRouter.signOut,
            responseType: Bool.self,
            useAuth: true
        ) { result in
            switch result {
            case .success:
                RealmService.shared.resetDB()
                let loginViewController = LoginViewController()
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
                {
                    loginViewController.toastMessage = TextLiteral.Common.withdrawComplete
                    keyWindow.replaceRootViewController(UINavigationController(rootViewController: loginViewController))
                }
                
            case .failure(let error):
                print("회원 탈퇴 실패: \(error.localizedDescription)")
            }
        }
    }
}
