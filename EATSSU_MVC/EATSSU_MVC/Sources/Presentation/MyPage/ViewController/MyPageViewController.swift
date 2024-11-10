//
//  File.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/05/22.
//

import Foundation
import WebKit

import FirebaseAnalytics
import KakaoSDKCommon
import KakaoSDKTalk
import Moya
import Realm
import SnapKit
import UIKit

final class MyPageViewController: BaseViewController {
	// MARK: - Properties
	
	private var myPageModel = MyPageModel()
	
	// MARK: - UI Components
    
	private let mypageView = MyPageView()
    
	// MARK: - Life Cycles
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
		setTableViewDelegate()
		loadSwitchStateFromUserDefaults()
	}
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
      
		myPageModel.nickName = UserInfoManager.shared.getCurrentUserInfo()?.nickname ?? NSLocalizedString(TextLiteral.MyPage.retryMessage, comment: "사용자 조회를 실패했을 때, 프로필에서 보여주는 문자열 리소스")
		mypageView.setUserInfo(nickname: myPageModel.nickName)
	}
    
	// MARK: - Functions
    
	override func setCustomNavigationBar() {
		super.setCustomNavigationBar()
		navigationItem.title = TextLiteral.MyPage.myPage
	}
    
	override func configureUI() {
		view.addSubviews(mypageView)
	}
    
	override func setLayout() {
		mypageView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}
    
	override func setButtonEvent() {
		mypageView.userNicknameButton
			.addTarget(self, action: #selector(changeNicknameButtonTapped), for: .touchUpInside)
		
		mypageView.userWithdrawButton
			.addTarget(self, action: #selector(userWithdrawButtonTapped), for: .touchUpInside)
	}
    
	private func setFirebaseTask() {
		FirebaseRemoteConfig.shared.fetchRestaurantInfo()
		
		#if DEBUG
		// 디버그 모드에서는 Firebase로 로그를 전송하면 안됨
		#else
		Analytics.logEvent("MypageViewControllerLoad", parameters: nil)
		#endif
	}
    
	@objc
	private func changeNicknameButtonTapped() {
		let setNickNameVC = SetNickNameViewController()
		navigationController?.pushViewController(setNickNameVC, animated: true)
	}
	
	@objc
	private func userWithdrawButtonTapped() {
		let userWithdrawViewController = UserWithdrawViewController(nickName: myPageModel.nickName)
		navigationController?.pushViewController(userWithdrawViewController, animated: true)
	}
    
	private func setTableViewDelegate() {
		mypageView.myPageTableView.dataSource = self
		mypageView.myPageTableView.delegate = self
	}
    
	private func logoutShowAlert() {
		let alertController = UIAlertController(title: TextLiteral.MyPage.logout,
		                                        message: TextLiteral.MyPage.logoutConfirmationMessage,
		                                        preferredStyle: UIAlertController.Style.alert)
        
		let cancelAction = UIAlertAction(title: TextLiteral.MyPage.cancel,
		                                 style: .default)
		
		let fixAction = UIAlertAction(title: TextLiteral.MyPage.logout, style: .default) { _ in
			RealmService.shared.resetDB()
          
			let loginViewController = LoginViewController()
			if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
			   let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
			{
				keyWindow.replaceRootViewController(UINavigationController(rootViewController: loginViewController))
			}
		}
        
		alertController.addAction(cancelAction)
		alertController.addAction(fixAction)

		present(alertController, animated: true, completion: nil)
	}
	
	/// UserDefaults에 스위치 상태 저장
	private func saveSwitchStateToUserDefaults() {
		print("사용자 푸시 알림 값을 앱 저장소에 보관합니다.")
		UserDefaults.standard.set(myPageModel.notificationState, forKey: TextLiteral.MyPage.pushNotificationUserSettingKey)
	}

	/// UserDefaults에서 스위치 상태 불러오기
	private func loadSwitchStateFromUserDefaults() {
		print("사용자 푸시 알림 값을 앱 저장소에서 불러옵니다.")
		myPageModel.notificationState = UserDefaults.standard.bool(forKey: TextLiteral.MyPage.pushNotificationUserSettingKey)
	}
}

// MARK: - TableView DataSource

extension MyPageViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return myPageModel.myPageTableLabelList.count
	}
    
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == MyPageLabels.NotificationSetting.rawValue {
			let cell = tableView
				.dequeueReusableCell(
					withIdentifier: NotificationSettingTableViewCell.identifier,
					for: indexPath) as! NotificationSettingTableViewCell
			
			// FIXME: 클로저의 순환참조 문제를 해결
			NotificationManager.shared.checkNotificationSetting { setting in
				switch setting.authorizationStatus {
				case .authorized, .notDetermined, .provisional, .ephemeral:
					DispatchQueue.main.async {
						cell.toggleSwitch.setOn(self.myPageModel.notificationState, animated: true)
					}
				case .denied:
					DispatchQueue.main.async {
						cell.toggleSwitch.setOn(false, animated: true)
					}
				@unknown default:
					// FIXME: 고의로 런타임을 일으키는 것은 좋은 코드가 아님
					fatalError()
				}
			}
			
			return cell
		} else {
			let cell = tableView
				.dequeueReusableCell(
					withIdentifier: MyPageTableDefaultCell.identifier,
					for: indexPath) as! MyPageTableDefaultCell
			
			let title = myPageModel.myPageTableLabelList[indexPath.row].titleLabel
			cell.serviceLabel.text = title
			return cell
		}
	}
}

// MARK: - UITableView Delegate

extension MyPageViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
    
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		switch indexPath.row {
		// "푸시 알림 설정" 스위치 토글
		case MyPageLabels.NotificationSetting.rawValue:
			
			// FIXME: 클로저의 순환참조 문제 해결
			NotificationManager.shared.checkNotificationSetting { setting in
				switch setting.authorizationStatus {
				case .denied:
					DispatchQueue.main.async {
						self.view.showToast(message: TextLiteral.MyPage.authorizeNotificationSettingMessage)
					}
				default:
					DispatchQueue.main.async {
						guard let cell = tableView.cellForRow(at: indexPath) as? NotificationSettingTableViewCell else { return }
						// 현재 스위치 상태를 반전
						let newSwitchState = !self.myPageModel.notificationState
						cell.toggleSwitch.setOn(newSwitchState, animated: true)
				
						// 스위치 상태를 업데이트
						self.myPageModel.notificationState = newSwitchState
						
						let currentDate = Date()
						let dateFormatter = DateFormatter()
						dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
						let formattedDate = dateFormatter.string(from: currentDate)
				
						if self.myPageModel.notificationState {
							print("푸시 알림을 발송합니다.")
							NotificationManager.shared.scheduleWeekday11AMNotification()
							self.view.showToast(message: "EAT-SSU 알림 수신을 동의하였습니다.\n(\(formattedDate))")
						} else {
							print("푸시 알림을 발송하지 않습니다.")
							NotificationManager.shared.cancelWeekday11AMNotification()
							self.view.showToast(message: "EAT-SSU 알림 수신을 거절하였습니다.\n(\(formattedDate))")
						}
				
						// UserDefaults에 상태 저장
						self.saveSwitchStateToUserDefaults()
					}
				}
			}
			
		// "내가 쓴 리뷰" 스크린으로 이동
		case MyPageLabels.MyReview.rawValue:
			let myReviewViewController = MyReviewViewController()
			navigationController?.pushViewController(myReviewViewController, animated: true)
	
		// "문의하기" 스크린으로 이동
		case MyPageLabels.Inquiry.rawValue:
			TalkApi.shared.chatChannel(channelPublicId: TextLiteral.KakaoChannel.id) { [weak self] error in
				if error != nil {
					if let kakaoChannelLink = URL(string: "http://pf.kakao.com/\(TextLiteral.KakaoChannel.id)") {
						UIApplication.shared.open(kakaoChannelLink)
					} else {
						self?.showAlertController(
							title: "다시 시도하세요",
							message: "에러가 발생했습니다",
							style: .default)
					}
				} else {
					// TODO: 카카오톡 채널 채팅방으로 연결 성공했을 때, 앱에서 동작되어야 하는 로직 고민
				}
			}
        
		// "서비스 이용약관" 스크린으로 이동
		case MyPageLabels.TermsOfUse.rawValue:
			let provisionViewController = ProvisionViewController(agreementType: .termsOfService)
			provisionViewController.navigationTitle = TextLiteral.MyPage.termsOfUse
			navigationController?.pushViewController(provisionViewController, animated: true)
        
		// "개인정보 이용약관" 스크린으로 이동
		case MyPageLabels.PrivacyTermsOfUse.rawValue:
			let provisionViewController = ProvisionViewController(agreementType: .privacyPolicy)
			provisionViewController.navigationTitle = TextLiteral.MyPage.privacyTermsOfUse
			navigationController?.pushViewController(provisionViewController, animated: true)
			
		// "만든사람들" 스크린으로 이동
		case MyPageLabels.Creator.rawValue:
			let creatorViewController = CreatorViewController()
			navigationController?.pushViewController(creatorViewController, animated: true)
			
		// "로그아웃" 팝업알림 표시
		case MyPageLabels.Logout.rawValue:
			logoutShowAlert()

		default:
			return
		}
	}
}
