//
//  File.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/05/22.
//

// Swift Module
import Foundation
import WebKit

// External Module
import FirebaseAnalytics
import SnapKit
import UIKit
import Moya
import Realm
import KakaoSDKCommon
import KakaoSDKTalk

final class MyPageViewController: BaseViewController {
    
    // MARK: - Properties
    
    private let myProvider = MoyaProvider<MyRouter>(plugins: [MoyaLoggingPlugin()])
    private var nickName = String()
	private let myPageTableLabelList = MyPageLocalData.myPageTableLabelList
	
    // MARK: - UI Components
    
    let mypageView = MyPageView()
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegate()
        Analytics.logEvent("MypageViewControllerLoad", parameters: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getMyInfo()
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
			.addTarget(
				self,
				action: #selector(didTappedChangeNicknameButton),
				for: .touchUpInside)
    }
	
	@objc
	func toggleSwitchTapped() {
		
	}
    
    @objc
    func didTappedChangeNicknameButton() {
        
        let setNickNameVC = SetNickNameViewController()
        self.navigationController?.pushViewController(setNickNameVC, animated: true)
    }
    
    func setDelegate() {
        mypageView.myPageTableView.dataSource = self
        mypageView.myPageTableView.delegate = self
    }
    
    /*
     해야 할 일
     - 알림 팝업을 띄우는 코드를 모듈화
     */
    private func logoutShowAlert() {
        let alert = UIAlertController(title: "로그아웃",
                                      message: "정말 로그아웃 하시겠습니까?",
                                      preferredStyle: UIAlertController.Style.alert
        )
        
        let cancelAction = UIAlertAction(title: "취소하기",
                                         style: .default,
                                         handler: nil)
        
        let fixAction = UIAlertAction(title: "로그아웃",
                                      style: .default,
                                      handler: { okAction in
            RealmService.shared.resetDB()
          
            let loginViewController = LoginViewController()
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                keyWindow.replaceRootViewController(UINavigationController(rootViewController: loginViewController))
            }
        })
        
        alert.addAction(cancelAction)
        alert.addAction(fixAction)

        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Server

extension MyPageViewController {
    private func getMyInfo() {
        self.myProvider.request(.myInfo) { response in
            switch response {
            case .success(let moyaResponse):
                do {
                    let responseData = try moyaResponse.map(BaseResponse<MyInfoResponse>.self)
                    self.mypageView.dataBind(model: responseData.result)
                    self.nickName = responseData.result.nickname ?? ""
                } catch(let err) {
                    print(err.localizedDescription)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
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
			
			cell.toggleSwitch.addTarget(self, action: #selector(toggleSwitchTapped), for: .valueChanged)
			
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
        // "내가 쓴 리뷰" 스크린으로 이동
        case MyPageLabels.MyReview.rawValue:
            let myReviewViewController = MyReviewViewController()
            self.navigationController?.pushViewController(myReviewViewController, animated: true)
		
		// "푸시 알림 설정" 스위치 토글
		case MyPageLabels.NotificationSetting.rawValue:
			if let cell = tableView.cellForRow(at: indexPath) as? NotificationSettingTableViewCell {
				// TODO: 스위치 값을 앱 저장소에 보관하고, 값에 따라 알림을 보내는 여부를 제어하는 코드를 설계할 것
				cell.toggleSwitch.isOn.toggle()
			}
			
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
            self.navigationController?.pushViewController(provisionViewController, animated: true)
        
        // "개인정보 이용약관" 스크린으로 이동
        case MyPageLabels.PrivacyTermsOfUse.rawValue:
            let provisionViewController = ProvisionViewController(agreementType: .privacyPolicy)
            provisionViewController.navigationTitle = TextLiteral.MyPage.privacyTermsOfUse
            self.navigationController?.pushViewController(provisionViewController, animated: true)
			
		// "만든사람들" 스크린으로 이동
        case MyPageLabels.Creator.rawValue:
            let creatorViewController = CreatorViewController()
            navigationController?.pushViewController(creatorViewController, animated: true)
			
		// "로그아웃" 팝업알림 표시
        case MyPageLabels.Logout.rawValue:
            self.logoutShowAlert()
        default:
            return
        }
    }
}
