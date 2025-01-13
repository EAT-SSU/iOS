import AuthenticationServices
import UIKit

import Firebase
import KakaoSDKUser
import Moya
import RealmSwift
import SnapKit
import Then

final class LoginViewController: BaseViewController {
    // MARK: - Properties

    var loginAfterlooking = true
    public static let isVacationPeriod = false
    private let viewModel = LoginViewModel()

    // MARK: - UI Components

    private let loginView = LoginView()

    // MARK: - Life Cycles

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        checkUser()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setFirebaseTask()
        bindViewModel()
    }

    // MARK: - Functions

    override func configureUI() {
        view.addSubviews(loginView)
    }

    override func setLayout() {
        loginView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func setButtonEvent() {
        loginView.kakaoLoginButton.addTarget(self, action: #selector(kakaoLoginButtonDidTapped), for: .touchUpInside)
        loginView.appleLoginButton.addTarget(self, action: #selector(appleLoginButtonDidTapped), for: .touchUpInside)
        loginView.lookingWithNoSignInButton.addTarget(self, action: #selector(lookingWithNoSignInButtonDidTapped), for: .touchUpInside)
    }

    private func setFirebaseTask() {
        FirebaseRemoteConfig.shared.fetchIsVacationPeriod()

        #if DEBUG
        #else
            Analytics.logEvent("LoginViewControllerLoad", parameters: nil)
        #endif
    }

    private func checkUser() {
        if viewModel.isLoggedIn {
            changeIntoHomeViewController()
        }
    }

    private func changeIntoHomeViewController() {
        let homeVC = HomeViewController()

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
        {
            keyWindow.replaceRootViewController(UINavigationController(rootViewController: homeVC))
        }
    }

    private func pushToNicknameVC() {
        let setNicknameViewController = SetNickNameViewController()
        navigationController?.pushViewController(setNicknameViewController, animated: true)
    }

    private func bindViewModel() {
        viewModel.userInfo.bind { [weak self] userInfo in
            guard let self = self else { return }
            if let userInfo = userInfo {
                if userInfo.nickname == nil {
                    self.pushToNicknameVC()
                } else {
                    self.changeIntoHomeViewController()
                }
            }
        }
    }

    // MARK: - Action Methods

    @objc
    private func kakaoLoginButtonDidTapped() {
        viewModel.loginWithKakao { [weak self] success in
            if success {
                self?.changeIntoHomeViewController()
            } else {
                self?.presentBottomAlert("Kakao login failed")
            }
        }
    }

    @objc
    private func appleLoginButtonDidTapped() {
        viewModel.loginWithApple { [weak self] success in
            if success {
                self?.changeIntoHomeViewController()
            } else {
                self?.presentBottomAlert("Apple login failed")
            }
        }
    }

    @objc
    private func lookingWithNoSignInButtonDidTapped() {
        changeIntoHomeViewController()
    }
}
