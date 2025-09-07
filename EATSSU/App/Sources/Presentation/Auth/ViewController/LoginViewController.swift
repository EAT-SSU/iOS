//
//  LoginViewController.swift
//  EatSSU-iOS
//
//  Edited by Jiwoong CHOi on 01/27/2025.
//

import AuthenticationServices
import UIKit

import Firebase
import KakaoSDKUser
import Moya
import RealmSwift
import SnapKit

final class LoginViewController: BaseViewController {
    // MARK: - Properties

    public static let isVacationPeriod = false
    public var toastMessage: String?
    private let authProvider = MoyaProvider<AuthRouter>(session: Session(interceptor: AuthInterceptor.shared))
    private let myProvider = MoyaProvider<MyRouter>(session: Session(interceptor: AuthInterceptor.shared))

    // MARK: - UI Components

    private let loginView = LoginView()

    // MARK: - Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleAutoLogin()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureFirebaseRemoteConfig()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showToastMessageIfNeeded()
        
        Analytics.logEvent(AnalyticsEventScreenView,
                           parameters: [AnalyticsParameterScreenName: FirebaseScreenID.log3,
                                       AnalyticsParameterScreenClass: "LoginViewController"])
    }

    // MARK: - Functions

    override func configureUI() {
        view.addSubview(loginView)
    }

    override func setLayout() {
        loginView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func setButtonEvent() {
        loginView.kakaoLoginButton.addTarget(
            self,
            action: #selector(kakaoLoginButtonDidTapped),
            for: .touchUpInside
        )
        loginView.appleLoginButton.addTarget(
            self,
            action: #selector(appleLoginButtonDidTapped),
            for: .touchUpInside
        )
        loginView.lookingWithNoSignInButton.addTarget(
            self,
            action: #selector(lookingWithNoSignInButtonDidTapped),
            for: .touchUpInside
        )
    }

    private func configureFirebaseRemoteConfig() {
        FirebaseRemoteConfig.shared.fetchIsVacationPeriod()

        #if !DEBUG
            Analytics.logEvent("LoginViewControllerLoad", parameters: nil)
        #endif
    }

    /// Realm에 저장된 토큰이 있는지 확인 후, 있으면 홈 화면으로 이동한다.
    private func handleAutoLogin() {
        guard hasStoredToken() else { return }
        #if DEBUG
            print("저장된 AccessToken: ", RealmService.shared.getToken())
        #endif
        changeIntoHomeViewController()
    }

    private func hasStoredToken() -> Bool {
        !RealmService.shared.getToken().isEmpty
    }

    private func changeIntoHomeViewController() {
        let customTabVC = CustomTabBarContainerController()
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
        else { return }

        keyWindow.replaceRootViewController(customTabVC)
    }

    /// 닉네임 설정이 필요한지 확인 후, 필요하면 닉네임 설정 화면으로, 아니면 홈 화면으로 이동한다.
    private func handleNicknameCheck(info: MyInfoResponse) {
        if let nickname = info.nickname {
            // 사용자의 닉네임을 업데이트하고 홈 화면으로 이동
            if let currentUserInfo = UserInfoManager.shared.getCurrentUserInfo() {
                UserInfoManager.shared.updateUserInfo(
                    for: currentUserInfo,
                    nickname: nickname,
                    collegeId: info.collegeId,
                    collegeName: info.collegeName,
                    departmentId: info.departmentId,
                    departmentName: info.departmentName
                )
            }
            changeIntoHomeViewController()
        } else {
            // 닉네임 설정이 필요한 경우
            let setNicknameVC = SetNickNameViewController()
            setNicknameVC.source = .signup
            navigationController?.pushViewController(setNicknameVC, animated: true)
        }
    }

    /// 토큰을 Realm에 저장하고, 디버깅 로그를 출력한다.
    private func storeTokensAndPrintDebugLogs(accessToken: String, refreshToken: String) {
        RealmService.shared.addToken(accessToken: accessToken, refreshToken: refreshToken)
        #if DEBUG
            print("⭐️⭐️ 토큰 저장 성공 ⭐️⭐️", accessToken)
        #endif
    }
    
    private func showToastMessageIfNeeded() {
        guard let toastMessage = self.toastMessage else { return }
        view.showToast(message: toastMessage)
    }

    // MARK: - 액션 메서드

    @objc
    private func kakaoLoginButtonDidTapped() {
        // 카카오톡이 설치되어 있으면 앱을 통해 로그인 시도
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { [weak self] _, error in
                guard let self else { return }
                if let error {
                    #if DEBUG
                        print(error.localizedDescription)
                    #endif
                    return
                }
                #if DEBUG
                    print("카카오톡으로 로그인 성공")
                #endif
                processKakaoUserLogin()
            }
        } else {
            // 카카오톡이 설치되어 있지 않으면 웹(카카오 계정) 로그인 시도
            UserApi.shared.loginWithKakaoAccount { [weak self] _, error in
                guard let self else { return }
                if let error {
                    print(error)
                    return
                }
                processKakaoUserLogin()
            }
        }
    }

    @objc
    private func appleLoginButtonDidTapped() {
        appleLoginRequest()
    }

    @objc
    private func lookingWithNoSignInButtonDidTapped() {
        changeIntoHomeViewController()
    }
}

// MARK: - 네트워크 요청

extension LoginViewController {
    /// 로그인 성공 공통 플로우: 디코딩 -> 토큰 저장 -> 유저 정보 생성 -> 프로필 조회
    private func handleLoginSuccess(
        moyaResponse: Response,
        accountType: UserInfo.AccountType
    ) {
        do {
            // 응답을 디코딩 시도
            let responseData = try JSONDecoder().decode(BaseResponse<SignResponse>.self, from: moyaResponse.data)
            guard let data = responseData.result else { return }
            
            let accessToken = data.accessToken
            let refreshToken = data.refreshToken
                
            // 토큰을 로컬에 저장
            storeTokensAndPrintDebugLogs(accessToken: accessToken, refreshToken: refreshToken)

            // 로컬 매니저에 유저 정보 생성
            _ = UserInfoManager.shared.createUserInfo(accountType: accountType)

            // 닉네임 등 정보를 확인하기 위해 프로필 조회
            getMyInfo()
        } catch {
            switch accountType {
            case .apple:
                presentBottomAlert("카카오톡으로 생성된 계정입니다.")
            case .kakao:
                presentBottomAlert("Apple로 생성된 계정입니다.")
            }

            #if DEBUG
                print("다른 계정으로 로그인 되어있을지도 모릅니다.")
                print(error.localizedDescription)
            #endif
        }
    }

    /// 카카오 로그인을 위해 서버에 이메일/아이디를 보내는 요청
    private func postKakaoLoginRequest(email: String, id: String) {
        authProvider.request(.kakaoLogin(param: KakaoLoginRequest(email: email,
                                                                  providerId: id))) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(moyaResponse):
                #if DEBUG
                    print("Kakao login response status code: \(moyaResponse.statusCode)")
                #endif
                handleLoginSuccess(moyaResponse: moyaResponse, accountType: .kakao)

            case let .failure(error):
                presentBottomAlert(error.localizedDescription)
                #if DEBUG
                    print(error.localizedDescription)
                #endif
            }
        }
    }

    /// 전달받은 identity token으로 Apple 로그인 요청
    private func postAppleLoginRequest(token: String) {
        authProvider.request(.appleLogin(param: AppleLoginRequest(identityToken: token))) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(moyaResponse):
                #if DEBUG
                    print("Apple 로그인 서버 응답코드: \(moyaResponse.statusCode)")
                #endif
                handleLoginSuccess(moyaResponse: moyaResponse, accountType: .apple)

            case let .failure(error):
                presentBottomAlert(error.localizedDescription)
                #if DEBUG
                    print(error.localizedDescription)
                #endif
            }
        }
    }

    /// 서버에서 현재 유저 정보를 조회
    private func getMyInfo() {
        myProvider.request(.myInfo) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(moyaResponse):
                do {
                    let responseData = try moyaResponse.map(BaseResponse<MyInfoResponse>.self)
                    guard let responseData = responseData.result else {
                        return
                    }
                    // 디버그 모드일 때만 받아온 유저 정보를 출력합니다.
//                    #if DEBUG
                    print("현재 로그인 정보: \(responseData)")
//                    #endif
                    handleNicknameCheck(info: responseData)
                } catch {
                    print(error.localizedDescription)
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - 카카오 사용자 정보 가져오기

extension LoginViewController {
    /// 카카오 로그인 이후, 카카오에서 직접 사용자 정보를 가져온 다음 백엔드로 넘긴다.
    private func processKakaoUserLogin() {
        UserApi.shared.me { [weak self] user, error in
            guard let self else { return }
            if let error {
                #if DEBUG
                    print("🎃 Kakao user info error: ", error)
                #endif
                return
            }
            guard let email = user?.kakaoAccount?.email,
                  let id = user?.id
            else { return }

            postKakaoLoginRequest(email: email, id: String(id))
        }
    }
}

// MARK: - 애플 로그인 메서드

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
    /// 애플 로그인 요청을 시작하며, 이름과 이메일 정보를 요청한다.
    private func appleLoginRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
        view.window!
    }

    func authorizationController(
        controller _: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email

            guard let identityToken = appleIDCredential.identityToken,
                  let tokenString = String(data: identityToken, encoding: .utf8)
            else { return }

            postAppleLoginRequest(token: tokenString)

            #if DEBUG
                print("User ID : \(userIdentifier)")
                print("User Email : \(email ?? "")")
                print("User Name : \((fullName?.givenName ?? "") + (fullName?.familyName ?? ""))")
                print("Token : \(tokenString)")
            #endif

        default:
            break
        }
    }

    func authorizationController(
        controller _: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        print("Apple 로그인 실패: \(error.localizedDescription)")
    }
}
