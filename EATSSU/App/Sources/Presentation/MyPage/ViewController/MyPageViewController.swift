//
//  MyPageViewController.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/05/22.
//

import UIKit
import WebKit

import KakaoSDKCommon
import KakaoSDKTalk
import Moya
import Realm
import SnapKit

final class MyPageViewController: BaseViewController {
    // MARK: - Properties

    private var nickName = ""
    private var switchState = false
    private let myPageTableLabelList = MyPageLocalData.myPageTableLabelList

    // MARK: - UI Components

    let mypageView = MyPageView()

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        setTableViewDelegate()
        loadSwitchStateFromUserDefaults()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        logScreenView(screenID: FirebaseScreenID.MyPage.mypage1)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        nickName = UserInfoManager.shared.getCurrentUserInfo()?.nickname ?? TextLiteral.MyPage.unknownUser
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
        mypageView.userWithdrawButton
            .addTarget(self, action: #selector(userWithdrawButtonTapped), for: .touchUpInside)
    }

    private func setFirebaseTask() {
        FirebaseRemoteConfig.shared.fetchRestaurantInfo()
    }
    
    @objc
    private func userWithdrawButtonTapped() {
        AnalyticsService.logEvent("click_mypage_menu", parameters: ["menu": "withdraw"])
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
        let alert = UIAlertController(title: TextLiteral.MyPage.logout,
                                      message: TextLiteral.MyPage.askLogout,
                                      preferredStyle: UIAlertController.Style.alert)

        let cancelAction = UIAlertAction(title: TextLiteral.Common.cancelDark,
                                         style: .default,
                                         handler: nil)

        let fixAction = UIAlertAction(title: TextLiteral.MyPage.logout,
                                      style: .default,
                                      handler: { _ in
                                          AnalyticsService.logEvent("click_logout")
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
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        myPageTableLabelList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == MyPageLabels.NotificationSetting.rawValue {
            let cell = tableView
                .dequeueReusableCell(
                    withIdentifier: NotificationSettingTableViewCell.identifier,
                    for: indexPath
                ) as! NotificationSettingTableViewCell
            
            // Task로 비동기 작업 처리
            _Concurrency.Task {
                let settings = await NotificationManager.shared.checkNotificationSetting()
                
                await MainActor.run {
                    switch settings.authorizationStatus {
                    case .authorized, .notDetermined, .provisional, .ephemeral:
                        cell.toggleSwitch.setOn(self.switchState, animated: true)
                    case .denied:
                        cell.toggleSwitch.setOn(false, animated: true)
                    @unknown default:
                        fatalError()
                    }
                }
            }
            return cell
        } else {
            let cell = tableView
                .dequeueReusableCell(
                    withIdentifier: MyPageTableDefaultCell.identifier,
                    for: indexPath
                ) as! MyPageTableDefaultCell
            
            let title = myPageTableLabelList[indexPath.row].titleLabel
            cell.serviceLabel.text = title
            return cell
        }
    }
}

// MARK: - UITableView Delegate

extension MyPageViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.row {
        // "푸시 알림 설정" 스위치 토글
        case MyPageLabels.NotificationSetting.rawValue:
            AnalyticsService.logEvent("click_mypage_menu", parameters: ["menu": "notification_setting"])
            handleNotificationSettingToggle(at: indexPath)

        // "내 정보" 스크린으로 이동
        case MyPageLabels.MyInfo.rawValue:
            AnalyticsService.logEvent("click_mypage_menu", parameters: ["menu": "my_info"])
            let setNickNameVC = SetNickNameViewController()
            setNickNameVC.source = .signup
            navigationController?.pushViewController(setNickNameVC, animated: true)

        // "내 리뷰" 스크린으로 이동
        case MyPageLabels.MyReview.rawValue:
            AnalyticsService.logEvent("click_mypage_menu", parameters: ["menu": "my_review"])
            let myReviewViewController = MyReviewViewController(nickname: nickName)
            navigationController?.pushViewController(myReviewViewController, animated: true)

        // "문의하기" 스크린으로 이동
        case MyPageLabels.Inquiry.rawValue:
            AnalyticsService.logEvent("click_mypage_menu", parameters: ["menu": "inquiry"])
            TalkApi.shared.chatChannel(channelPublicId: TextLiteral.KakaoChannel.id) { [weak self] error in
                if error != nil {
                    if let kakaoChannelLink = URL(string: "http://pf.kakao.com/\(TextLiteral.KakaoChannel.id)") {
                        UIApplication.shared.open(kakaoChannelLink)
                    } else {
                        self?.showAlertController(
                            title: TextLiteral.Common.retry,
                            message: TextLiteral.Common.errorOccured,
                            style: .default
                        )
                    }
                } else {
                    // TODO: 카카오톡 채널 채팅방으로 연결 성공했을 때, 앱에서 동작되어야 하는 로직 고민
                }
            }

        // "서비스 이용약관" 스크린으로 이동
        case MyPageLabels.TermsOfUse.rawValue:
            AnalyticsService.logEvent("click_mypage_menu", parameters: ["menu": "terms_of_use"])
            let provisionViewController = ProvisionViewController(agreementType: .termsOfService)
            provisionViewController.navigationTitle = TextLiteral.MyPage.termsOfUse
            navigationController?.pushViewController(provisionViewController, animated: true)

        // "개인정보 이용약관" 스크린으로 이동
        case MyPageLabels.PrivacyTermsOfUse.rawValue:
            AnalyticsService.logEvent("click_mypage_menu", parameters: ["menu": "privacy_policy"])
            let provisionViewController = ProvisionViewController(agreementType: .privacyPolicy)
            provisionViewController.navigationTitle = TextLiteral.MyPage.privacyTermsOfUse
            navigationController?.pushViewController(provisionViewController, animated: true)

        // "만든사람들" 스크린으로 이동
        case MyPageLabels.Creator.rawValue:
            AnalyticsService.logEvent("click_mypage_menu", parameters: ["menu": "creator"])
            let creatorViewController = CreatorViewController()
            navigationController?.pushViewController(creatorViewController, animated: true)

        // "로그아웃" 팝업알림 표시
        case MyPageLabels.Logout.rawValue:
            logoutShowAlert()

        default:
            return
        }
    }
    
    /// 알림 설정 토글 처리
    private func handleNotificationSettingToggle(at indexPath: IndexPath) {
        _Concurrency.Task {
            do {
                let newState = try await NotificationManager.shared.handleNotificationToggle(currentState: switchState)
                
                // 메인 스레드에서 UI 업데이트
                await MainActor.run {
                    // 스위치 상태 업데이트
                    self.switchState = newState
                    self.saveSwitchStateToUserDefaults()
                    
                    // UI 업데이트
                    if let cell = self.mypageView.myPageTableView.cellForRow(at: indexPath) as? NotificationSettingTableViewCell {
                        cell.toggleSwitch.setOn(newState, animated: true)
                    }
                    
                    // 토스트 메시지
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                    let formattedDate = dateFormatter.string(from: Date())
                    
                    let message = newState
                        ? TextLiteral.MyPage.agreeNoti(date: formattedDate)
                        : TextLiteral.MyPage.disagreeNoti(date: formattedDate)
                    
                    self.showToast(message: message, type: .info)
                }
                
            } catch let error as NotificationManager.NotificationError {
                await MainActor.run {
                    switch error {
                    case .permissionDenied:
                        self.showNotificationPermissionAlert()
                    case .unknown:
                        self.showToast(message: TextLiteral.MyPage.notiSettingError, type: .danger)
                    }
                }
            }
        }
    }
    
    /// 알림 권한 설정 Alert 표시
    private func showNotificationPermissionAlert() {
        let error = NotificationManager.NotificationError.permissionDenied
        
        let alert = UIAlertController(
            title: error.message,
            message: error.description,
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: TextLiteral.Common.moveToSetting, style: .default) { _ in
            NotificationManager.shared.openNotificationSettings() 
        }
        
        let cancelAction = UIAlertAction(title: TextLiteral.Common.cancel, style: .cancel)
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}
