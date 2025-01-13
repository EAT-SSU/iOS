import Foundation
import AuthenticationServices
import KakaoSDKUser
import Moya
import RealmSwift

class LoginViewModel {
    // Properties for user authentication and login status
    var isLoggedIn: Bool = false
    var userInfo: UserInfo?

    private let authProvider = MoyaProvider<AuthRouter>(plugins: [MoyaLoggingPlugin()])
    private let myProvider = MoyaProvider<MyRouter>(plugins: [MoyaLoggingPlugin()])

    // Methods for handling login with Kakao and Apple
    func loginWithKakao(completion: @escaping (Bool) -> Void) {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                if let error = error {
                    print(error)
                    completion(false)
                } else {
                    print("loginWithKakaoTalk() success.")
                    self.getUserInfo { success in
                        completion(success)
                    }
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                if let error = error {
                    print(error)
                    completion(false)
                } else {
                    self.getUserInfo { success in
                        completion(success)
                    }
                }
            }
        }
    }

    func loginWithApple(completion: @escaping (Bool) -> Void) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    // Methods for checking user information and updating UI
    private func getUserInfo(completion: @escaping (Bool) -> Void) {
        UserApi.shared.me { user, error in
            if let error = error {
                print("🎃", error)
                completion(false)
            } else {
                guard let email = user?.kakaoAccount?.email else { return }
                guard let id = user?.id else { return }
                self.postKakaoLoginRequest(email: email, id: String(id)) { success in
                    completion(success)
                }
            }
        }
    }

    private func postKakaoLoginRequest(email: String, id: String, completion: @escaping (Bool) -> Void) {
        authProvider.request(.kakaoLogin(param: KakaoLoginRequest(email: email, providerId: id))) { response in
            switch response {
            case let .success(moyaResponse):
                do {
                    print(moyaResponse.statusCode)
                    let responseData = try moyaResponse.map(BaseResponse<SignResponse>.self)
                    self.addTokenInRealm(accessToken: responseData.result.accessToken, refreshToken: responseData.result.refreshToken)
                    self.userInfo = UserInfoManager.shared.createUserInfo(accountType: .kakao)
                    self.getMyInfo { success in
                        completion(success)
                    }
                } catch let err {
                    print(err.localizedDescription)
                    completion(false)
                }
            case let .failure(err):
                print(err.localizedDescription)
                completion(false)
            }
        }
    }

    private func addTokenInRealm(accessToken: String, refreshToken: String) {
        RealmService.shared.addToken(accessToken: accessToken, refreshToken: refreshToken)
        print("⭐️⭐️토큰 저장 성공~⭐️⭐️")
        print(RealmService.shared.getToken())
        print(RealmService.shared.getRefreshToken())
    }

    private func getMyInfo(completion: @escaping (Bool) -> Void) {
        myProvider.request(.myInfo) { response in
            switch response {
            case let .success(moyaResponse):
                do {
                    let responseData = try moyaResponse.map(BaseResponse<MyInfoResponse>.self)
                    self.checkUserNickname(info: responseData.result)
                    completion(true)
                } catch let err {
                    print(err.localizedDescription)
                    completion(false)
                }
            case let .failure(err):
                print(err.localizedDescription)
                completion(false)
            }
        }
    }

    private func checkUserNickname(info: MyInfoResponse) {
        switch info.nickname {
        case nil:
            // Handle navigation to SetNickNameViewController
            break
        default:
            if let currentUserInfo = UserInfoManager.shared.getCurrentUserInfo() {
                UserInfoManager.shared.updateNickname(for: currentUserInfo, nickname: info.nickname ?? "")
            }
            // Handle navigation to HomeViewController
            break
        }
    }
}

extension LoginViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            let idToken = appleIDCredential.identityToken!
            let tokenStr = String(data: idToken, encoding: .utf8)

            postAppleLoginRequest(token: tokenStr ?? "") { success in
                // Handle success or failure
            }
            print("User ID : \(userIdentifier)")
            print("User Email : \(email ?? "")")
            print("User Name : \((fullName?.givenName ?? "") + (fullName?.familyName ?? ""))")
            print("token : \(String(describing: tokenStr))")
        default:
            break
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Login in Fail.")
    }

    private func postAppleLoginRequest(token: String, completion: @escaping (Bool) -> Void) {
        authProvider.request(.appleLogin(param: AppleLoginRequest(identityToken: token))) { response in
            switch response {
            case let .success(moyaResponse):
                do {
                    print(moyaResponse.statusCode)
                    let responseData = try JSONDecoder().decode(BaseResponse<SignResponse>.self, from: moyaResponse.data)
                    self.addTokenInRealm(accessToken: responseData.result.accessToken, refreshToken: responseData.result.refreshToken)
                    self.userInfo = UserInfoManager.shared.createUserInfo(accountType: .apple)
                    self.getMyInfo { success in
                        completion(success)
                    }
                } catch let err {
                    print(err.localizedDescription)
                    completion(false)
                }
            case let .failure(err):
                print(err.localizedDescription)
                completion(false)
            }
        }
    }
}
