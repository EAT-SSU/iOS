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

    private enum URLConstants {
        static let creatorsNotion = "https://eat-ssu.notion.site/1d2eeef75a16814db1e5c5abaf40cf6a"
        static let instagram = "https://www.instagram.com/eatssu.official/"
    }

    private var nickName = ""
    private var switchState = false
    private let sections = MyPageSectionData.sections
    
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
        
        let userInfo = UserInfoManager.shared.getCurrentUserInfo()

        nickName = userInfo?.nickname ?? TextLiteral.MyPage.unknownUser

        mypageView.setUserInfo(
            nickname: nickName,
            collegeName: userInfo?.collegeName,
            departmentName: userInfo?.departmentName
        )
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
        MyPageAnalyticsManager.shared.logClickMyPageMenu(menu: .withdraw)
        let userWithdrawViewController = UserWithdrawViewController(nickName: nickName)
        navigationController?.pushViewController(userWithdrawViewController, animated: true)
    }
    
    /// TableViewDelegate & DataSource를 해당 클래스로 할당합니다.
    private func setTableViewDelegate() {
        mypageView.myPageTableView.dataSource = self
        mypageView.myPageTableView.delegate = self
        
        if #available(iOS 15.0, *) {
            mypageView.myPageTableView.sectionHeaderTopPadding = 0
        }
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
            AnalyticsIdentityManager.reset()
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
    
    /// indexPath로 현재 item을 가져오기
    private func item(at indexPath: IndexPath) -> MyPageLabels {
        return sections[indexPath.section].items[indexPath.row]
    }
}

// MARK: - TableView DataSource

extension MyPageViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return sections[section].items.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let item = item(at: indexPath)
        
        switch item {
        case .notificationSetting:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NotificationSettingTableViewCell.identifier,
                for: indexPath
            ) as? NotificationSettingTableViewCell else {
                return UITableViewCell()
            }
            
            cell.configure(with: item)
            
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
            
        default:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: MyPageTableDefaultCell.identifier,
                for: indexPath
            ) as? MyPageTableDefaultCell else {
                return UITableViewCell()
            }
            
            cell.configure(with: item)
            
            return cell
        }
    }
}

// MARK: - UITableView Delegate

extension MyPageViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        let item = item(at: indexPath)
        return MyPageTableMetric.rowHeight(for: item)
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        return MyPageTableMetric.headerHeight
    }
    
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.text = sections[section].headerTitle
        titleLabel.font = .caption1
        titleLabel.textColor = .gray500
        
        headerView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(24)
            $0.centerY.equalToSuperview()
        }
        
        return headerView
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch item(at: indexPath) {
        // "푸시 알림 설정" 스위치 토글
        case .notificationSetting:
            MyPageAnalyticsManager.shared.logClickMyPageMenu(menu: .notificationSetting)
            handleNotificationSettingToggle(at: indexPath)

        // "내 정보" 스크린으로 이동
        case .myInfo:
            MyPageAnalyticsManager.shared.logClickMyPageMenu(menu: .myInfo)
            let setNickNameVC = SetNickNameViewController()
            setNickNameVC.source = .mypage
            navigationController?.pushViewController(setNickNameVC, animated: true)

        // "내 리뷰" 스크린으로 이동
        case .myReview:
            MyPageAnalyticsManager.shared.logClickMyPageMenu(menu: .myReview)
            let myReviewViewController = MyReviewViewController(nickname: nickName)
            navigationController?.pushViewController(myReviewViewController, animated: true)

        // "문의하기" 스크린으로 이동
        case .inquiry:
            MyPageAnalyticsManager.shared.logClickMyPageMenu(menu: .inquiry)
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

        // "만든사람들" 노션 페이지로 이동 (앱 내 웹뷰)
        case .creators:
            MyPageAnalyticsManager.shared.logClickMyPageMenu(menu: .creator)
            if let creatorsURL = URL(string: URLConstants.creatorsNotion) {
                let creatorsWebVC = ProvisionViewController(url: creatorsURL)
                creatorsWebVC.navigationTitle = TextLiteral.MyPage.creators
                navigationController?.pushViewController(creatorsWebVC, animated: true)
            }

        // "EAT-SSU 인스타그램" 외부 링크 열기
        case .instagram:
            MyPageAnalyticsManager.shared.logClickMyPageMenu(menu: .insta)
            if let instagramURL = URL(string: URLConstants.instagram) {
                UIApplication.shared.open(instagramURL)
            }

        // "언어 설정" 스크린으로 이동
        case .languageSetting:
            MyPageAnalyticsManager.shared.logClickMyPageMenu(menu: .languageSetting)
            let languageSettingViewController = LanguageSettingViewController()
            navigationController?.pushViewController(languageSettingViewController, animated: true)

        // "약관 및 정책" 스크린으로 이동
        case .termsAndPolicy:
            let termsAndPolicyViewController = TermsAndPolicyViewController()
            navigationController?.pushViewController(termsAndPolicyViewController, animated: true)

        // "로그아웃" 팝업알림 표시
        case .logout:
            MyPageAnalyticsManager.shared.logClickMyPageMenu(menu: .logout)
            logoutShowAlert()
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat {
        return section == sections.count - 1 ? CGFloat.leastNormalMagnitude : MyPageTableMetric.footerHeight
    }

    func tableView(
        _ tableView: UITableView,
        viewForFooterInSection section: Int
    ) -> UIView? {
        guard section != sections.count - 1 else {
            return nil
        }
        
        let footerView = UIView()
        
        let dividerView = UIView()
        dividerView.backgroundColor = .gray300
        
        footerView.addSubview(dividerView)
        
        dividerView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.horizontalEdges.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        return footerView
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
