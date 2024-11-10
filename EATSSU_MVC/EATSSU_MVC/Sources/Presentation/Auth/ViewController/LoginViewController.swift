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
import PromiseKit
import RealmSwift
import SnapKit
import Then

final class LoginViewController: BaseViewController {
	// MARK: - Properties
    
	var loginAfterlooking = true
	public static let isVacationPeriod = false
	
	var model = LoginModel()
    
	// MARK: - UI Components
    
	private let loginView = LoginView()

	// MARK: - Life Cycles
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		checkUser()
	}
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
		model.activateFirebaseTask()
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
    
	private func getUserInfo() {
		UserApi.shared.me { user, error in
			if let error = error {
				// FIXME: 이모지는 좀....
				print("🎃", error)
			} else {
				guard let email = user?.kakaoAccount?.email else { return }
				guard let id = user?.id else { return }
				
				firstly {
					self.model.postKakaoLoginRequest(email: email, id: String(id))
				}.done {
					firstly {
						self.model.getMyInfo()
					}.done { responseData in
						self.changeViewControllerAfterCheckNickName(info: responseData.result)
					}.catch { err in
						self.presentBottomAlert(err.localizedDescription)
					}
				}.catch { err in
					self.presentBottomAlert(err.localizedDescription)
				}
			}
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
    
	private func checkUser() {
		// 자동 로그인 풀고 싶을 때 한번 실행시켜주기
		// self.realm.resetDB()
        
		/// 자동 로그인
		if model.checkRealmToken() {
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
    
	private func changeViewControllerAfterCheckNickName(info: MyInfoResponse) {
		switch info.nickname {
		case nil:
			pushToNicknameVC()
		default:
			if let currentUserInfo = UserInfoManager.shared.getCurrentUserInfo() {
				UserInfoManager.shared.updateNickname(for: currentUserInfo, nickname: info.nickname ?? "")
			}
			changeIntoHomeViewController()
		}
	}
    
	// MARK: - Action Methods
    
	@objc
	private func kakaoLoginButtonDidTapped() {
		// 카카오톡 앱이 설치되어 있는지 확인
		if UserApi.isKakaoTalkLoginAvailable() {
			// 카카오톡 앱을 통한 로그인 시도
			UserApi.shared.loginWithKakaoTalk { oauthToken, error in
				if let error = error {
					print(error)
				} else {
					print("loginWithKakaoTalk() success.")
					self.getUserInfo()
					_ = oauthToken
				}
			}
		} else {
			// 카카오 계정을 통한 웹 로그인 시도
			UserApi.shared.loginWithKakaoAccount { oauthToken, error in
				if let error = error {
					print(error)
				} else {
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

// MARK: - ASAuthorization Controller Delegate

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
	func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		return view.window!
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
    
			firstly {
				model.postAppleLoginRequest(token: tokeStr ?? "")
			}.done {
				firstly {
					self.model.getMyInfo()
				}.done { responseData in
					self.changeViewControllerAfterCheckNickName(info: responseData.result)
				}.catch { err in
					self.presentBottomAlert(err.localizedDescription)
				}
			}.catch { err in
				self.presentBottomAlert(err.localizedDescription)
			}
			
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
