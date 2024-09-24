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
    
	private let myProvider = MoyaProvider<MyRouter>(plugins: [MoyaLoggingPlugin()])
	private var nickName = ""
	private var switchState = false
	private let myPageTableLabelList = MyPageLocalData.myPageTableLabelList
	
	// MARK: - UI Components
    
	let mypageView = MyPageView()
    
	// MARK: - Life Cycles
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
		Analytics.logEvent("MypageViewControllerLoad", parameters: nil)
		setTableViewDelegate()
		loadSwitchStateFromUserDefaults()
	}
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
     
		nickName = UserInfoManager.shared.getCurrentUserInfo()?.nickname ?? "실패"
		mypageView.setUserInfo(nickname: nickName)
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
			.addTarget(self, action: #selector(didTappedChangeNicknameButton), for: .touchUpInside)
		
		mypageView.userWithdrawButton
			.addTarget(self, action: #selector(userWithdrawButtonTapped), for: .touchUpInside)
	}
    
	@objc
	private func didTappedChangeNicknameButton() {
		let setNickNameVC = SetNickNameViewController()
		navigationController?.pushViewController(setNickNameVC, animated: true)
	}
	
	@objc
	private func userWithdrawButtonTapped() {
		let userWithdrawViewController = UserWithdrawViewController(nickName: nickName)
		navigationController?.pushViewController(userWithdrawViewController, animated: true)
	}
    
	/// TableViewDelegate & DataSource를 해당 클래스로 할당합니다.
	private func setTableViewDelegate() {
		mypageView.myPageTableView.dataSource = self
		mypageView.myPageTableView.delegate = self
	}
    
	/// 로그아웃 Alert를 스크린에 표시하는 메소드
	private func logoutShowAlert() {
		let alert = UIAlertController(title: "로그아웃",
		                              message: "정말 로그아웃 하시겠습니까?",
		                              preferredStyle: UIAlertController.Style.alert)
        
		let cancelAction = UIAlertAction(title: "취소하기",
		                                 style: .default,
		                                 handler: nil)
        
		let fixAction = UIAlertAction(title: "로그아웃",
		                              style: .default,
		                              handler: { _ in
		                              	RealmService.shared.resetDB()
          
		                              	let loginViewController = LoginViewController()
		                              	if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
		                              	   let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
		                              	{
		                              		keyWindow.replaceRootViewController(UINavigationController(rootViewController: loginViewController))
		                              	}
		                              })
        
		alert.addAction(cancelAction)
		alert.addAction(fixAction)

		present(alert, animated: true, completion: nil)
	}
	
	/// UserDefaults에 스위치 상태 저장
	private func saveSwitchStateToUserDefaults() {
		print("사용자 푸시 알림 값을 앱 저장소에 보관합니다.")
		UserDefaults.standard.set(switchState, forKey: TextLiteral.MyPage.pushNotificationUserSettingKey)
	}

	/// UserDefaults에서 스위치 상태 불러오기
	private func loadSwitchStateFromUserDefaults() {
		print("사용자 푸시 알림 값을 앱 저장소에서 불러옵니다.")
		switchState = UserDefaults.standard.bool(forKey: TextLiteral.MyPage.pushNotificationUserSettingKey)
	}
}

// MARK: - TableView DataSource

extension MyPageViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return myPageTableLabelList.count
	}
    
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == MyPageLabels.NotificationSetting.rawValue {
			let cell = tableView
				.dequeueReusableCell(
					withIdentifier: NotificationSettingTableViewCell.identifier,
					for: indexPath) as! NotificationSettingTableViewCell
			
			NotificationManager.shared.checkNotificationSetting { setting in
				switch setting.authorizationStatus {
				case .authorized, .notDetermined, .provisional, .ephemeral:
					DispatchQueue.main.async {
						cell.toggleSwitch.setOn(self.switchState, animated: true)
					}
				case .denied:
					DispatchQueue.main.async {
						cell.toggleSwitch.setOn(false, animated: true)
					}
				@unknown default:
					fatalError()
				}
			}
			
			return cell
		} else {
			let cell = tableView
				.dequeueReusableCell(
					withIdentifier: MyPageTableDefaultCell.identifier,
					for: indexPath) as! MyPageTableDefaultCell
			
			let title = myPageTableLabelList[indexPath.row].titleLabel
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
						let newSwitchState = !self.switchState
						cell.toggleSwitch.setOn(newSwitchState, animated: true)
				
						// 스위치 상태를 업데이트
						self.switchState = newSwitchState
						
						let currentDate = Date()
						let dateFormatter = DateFormatter()
						dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
						let formattedDate = dateFormatter.string(from: currentDate)
				
						if self.switchState {
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
