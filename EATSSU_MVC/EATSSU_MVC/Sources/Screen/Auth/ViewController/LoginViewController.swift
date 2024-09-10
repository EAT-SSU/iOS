//
//  LoginViewController.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/06/26.
//

import AuthenticationServices
import UIKit

import Firebase
import KakaoSDKUser
import Moya
import SnapKit
import RealmSwift
import Then

final class LoginViewController: BaseViewController {
    
    // MARK: - Properties
    
    var loginAfterlooking = true
    
    // MARK: - UI Components
    
    private let loginView = LoginView()
    private let authProvider = MoyaProvider<AuthRouter>(plugins: [MoyaLoggingPlugin()])
    private let myProvider = MoyaProvider<MyRouter>(plugins: [MoyaLoggingPlugin()])


    // MARK: - Life Cycles
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        checkUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Analytics.logEvent("LoginViewControllerLoad", parameters: nil)
    }
    
    // MARK: - Functions
    
    override func configureUI() {
        view.addSubviews(loginView)
    }
    
    override func setLayout() {
      /*
       해야 할 일
       - View Hierarchy를 확인하면 이상하게 배치가 되어있다.
       - 해당 사항을 최초작성자에게 부탁한 후 재설계할 것.
       */
        loginView.snp.makeConstraints { make in
          make.edges.equalToSuperview()
        }
    }
    
    override func setButtonEvent() {
        loginView.kakaoLoginButton.addTarget(self, action: #selector(kakaoLoginButtonDidTapped), for: .touchUpInside)
        loginView.appleLoginButton.addTarget(self, action: #selector(appleLoginButtonDidTapped), for: .touchUpInside)
        loginView.lookingWithNoSignInButton.addTarget(self, action: #selector(lookingWithNoSignInButtonDidTapped), for: .touchUpInside)
    }

    private func getUserInfo() {
        UserApi.shared.me { user, error in
            if let error = error {
                print("🎃", error)
            } else {
                guard let email = user?.kakaoAccount?.email else { return }
                guard let id = user?.id else { return }
                self.postKakaoLoginRequest(email: email, id: String(id))
            }
        }
    }
    
    private func addTokenInRealm(accessToken:String, refreshToken:String) {
        RealmService.shared.addToken(accessToken: accessToken, refreshToken: refreshToken)
        print("⭐️⭐️토큰 저장 성공~⭐️⭐️")
        print(RealmService.shared.getToken())
        print(RealmService.shared.getRefreshToken())
    }
    
    private func changeIntoHomeViewController() {
        let homeVC = HomeViewController()

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
          keyWindow.replaceRootViewController(UINavigationController(rootViewController: homeVC))
        }
    }
    
    private func pushToNicknameVC() {
        let setNicknameViewController = SetNickNameViewController()
        navigationController?.pushViewController(setNicknameViewController, animated: true)
    }
    
    private func checkRealmToken() -> Bool {
        if RealmService.shared.getToken() == "" {
            return false
        } else {
            return true
        }
    }
    
    private func checkUser() {
        /// 자동 로그인 풀고 싶을 때 한번 실행시켜주기
//        self.realm.resetDB()
        
        /// 자동 로그인
        if checkRealmToken() {
            
            print(RealmService.shared.getToken())
            changeIntoHomeViewController()
        }
    }
    
    /// 요청으로 얻을 수 있는 값들: 이름, 이메일로 설정
    private func appleLoginRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func checkUserNickname(info: MyInfoResponse) {
        switch info.nickname {
        case nil:
            self.pushToNicknameVC()
        default:
            self.changeIntoHomeViewController()
        }
    }
    
    // MARK: - Action Methods
    
    @objc
    private func kakaoLoginButtonDidTapped() {
        // 카카오톡 앱이 설치되어 있는지 확인
        if UserApi.isKakaoTalkLoginAvailable() {
            // 카카오톡 앱을 통한 로그인 시도
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")
                    self.getUserInfo()
                    _ = oauthToken
                }
            }
        } else {
            // 카카오 계정을 통한 웹 로그인 시도
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    self.getUserInfo()
                    _ = oauthToken
                }
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

// MARK: - Network

extension LoginViewController {
    private func postKakaoLoginRequest(email: String, id: String) {
        self.authProvider.request(.kakaoLogin(param: KakaoLoginRequest(email: email,
                                                                       providerId: id))) { response in
            switch response {
            case .success(let moyaResponse):
                do {
                    print(moyaResponse.statusCode)
                    let responseData = try moyaResponse.map(BaseResponse<SignResponse>.self)
                    self.addTokenInRealm(accessToken: responseData.result.accessToken,
                                         refreshToken: responseData.result.refreshToken)
                    self.getMyInfo()
                } catch(let err) {
                    self.presentBottomAlert(err.localizedDescription)
                    print(err.localizedDescription)
                }
            case .failure(let err):
                self.presentBottomAlert(err.localizedDescription)
                print(err.localizedDescription)
            }
        }
    }
    
    private func getMyInfo() {
        self.myProvider.request(.myInfo) { response in
            switch response {
            case .success(let moyaResponse):
                do {
                    let responseData = try moyaResponse.map(BaseResponse<MyInfoResponse>.self)
                    self.checkUserNickname(info: responseData.result)
                } catch(let err) {
                    print(err.localizedDescription)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
  
    private func postAppleLoginRequest(token: String) {
        self.authProvider.request(.appleLogin(param: AppleLoginRequest(identityToken: token))) { response in
            switch response {
            case .success(let moyaResponse):
                do {
                    print(moyaResponse.statusCode)
                  let responseData = try JSONDecoder().decode(BaseResponse<SignResponse>.self, from: moyaResponse.data)
                    self.addTokenInRealm(accessToken: responseData.result.accessToken,
                                         refreshToken: responseData.result.refreshToken)
                    self.getMyInfo()
                } catch(let err) {
                    self.presentBottomAlert(err.localizedDescription)
                    print(err.localizedDescription)
                }
            case .failure(let err):
                self.presentBottomAlert(err.localizedDescription)
                print(err.localizedDescription)
            }
        }
    }
}

// MARK: - ASAuthorization Controller Delegate

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    // Apple ID 연동 성공 시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
            // Apple ID
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // 계정 정보 가져오기
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            let idToken = appleIDCredential.identityToken!
            let tokeStr = String(data: idToken, encoding: .utf8)
    
            postAppleLoginRequest(token: tokeStr ?? "")
            print("User ID : \(userIdentifier)")
            print("User Email : \(email ?? "")")
            print("User Name : \((fullName?.givenName ?? "") + (fullName?.familyName ?? ""))")
            print("token : \(String(describing: tokeStr))")
            
        default:
            break
        }
    }
    
    // Apple ID 연동 실패 시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Login in Fail.")
    }
}

