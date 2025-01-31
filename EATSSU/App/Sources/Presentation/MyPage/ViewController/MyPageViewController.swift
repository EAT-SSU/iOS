//
//  MyPageViewController.swift
//  EATSSU
//
//  Edited by Jiwoong CHOi on 01/31/2025.
//

import Foundation
import UIKit
import WebKit

import EATSSUKit

import FirebaseAnalytics
import KakaoSDKCommon
import KakaoSDKTalk
import Moya
import Realm
import SnapKit

/// - Note: 마이페이지 화면을 담당하는 뷰컨트롤러입니다.
///         사용자 정보, 로그아웃, 리뷰, 알림 설정 등
///         다양한 마이페이지 기능을 구성합니다.
final class MyPageViewController: BaseViewController {
    // MARK: - Properties

    //======================================================================
    /// - Note: MyPage와 관련된 네트워크 통신용 Moya Provider
    private let myProvider = MoyaProvider<MyRouter>(plugins: [ESMoyaLoggingPlugin()])

    /// - Note: 사용자 닉네임
    private var nickName = ""

    /// - Note: 푸시 알림 스위치 상태
    private var switchState = false

    /// - Note: 테이블에 표시될 셀 정보(라벨, 항목 등)
    private let myPageTableLabelList = MyPageSettingList.myPageTableLabelList

    /// - Note: 현재 액세스 토큰의 보유 여부
    private let hasAccessToken: Bool

    /// - Note: UI를 구성하는 커스텀 뷰
    let mypageView = MyPageView()

    // MARK: - Initializer

    //======================================================================
    /// - Parameter hasAccessToken: 액세스 토큰이 존재하는지 여부를 나타내는 Bool 값
    init(hasAccessToken: Bool) {
        self.hasAccessToken = hasAccessToken
        super.init(nibName: nil, bundle: nil)
    }

    /// - Warning: 스토리보드를 사용하지 않으므로, 필수 생성자를 구현만 해둡니다.
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    //======================================================================
    /// - Note: 화면이 메모리에 로드된 직후 호출됩니다.
    ///         테이블 뷰의 델리게이트/데이터소스 연결, 스위치 상태 불러오기를 수행합니다.
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        loadSwitchStateFromUserDefaults()
    }

    /// - Note: 화면이 나타날 때마다 호출됩니다.
    ///         액세스 토큰 보유 여부에 따라 닉네임을 업데이트합니다.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if hasAccessToken {
            nickName = UserInfoManager.shared.getCurrentUserInfo()?.nickname ?? "다시 시도하세요"
        } else {
            nickName = "로그인을 해주세요"
        }
        mypageView.setUserInfo(nickname: nickName)
    }

    // MARK: - BaseViewController Overrides

    //======================================================================
    /// - Note: 상단 내비게이션 바를 설정합니다.
    override func setESNavigationBar() {
        super.setESNavigationBar()
        navigationItem.title = ESTextLiteral.MyPage.myPage
    }

    /// - Note: 기본 UI 요소를 View 계층에 추가합니다.
    override func configureUI() {
        view.addSubviews(mypageView)
    }

    /// - Note: UI 요소의 오토레이아웃 제약을 설정합니다.
    override func setLayout() {
        mypageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    /// - Note: 버튼들의 액션을 연결합니다.
    override func setButtonEvent() {
        mypageView.userNicknameButton
            .addTarget(self, action: #selector(didTappedChangeNicknameButton), for: .touchUpInside)

        mypageView.userWithdrawButton
            .addTarget(self, action: #selector(userWithdrawButtonTapped), for: .touchUpInside)
    }

    // MARK: - Actions

    //======================================================================
    /// - Note: 닉네임 변경 버튼을 탭했을 때 호출됩니다.
    ///         닉네임 설정 화면으로 이동합니다.
    @objc
    private func didTappedChangeNicknameButton() {
        let setNickNameVC = SetNickNameViewController()
        navigationController?.pushViewController(setNickNameVC, animated: true)
    }

    /// - Note: 회원탈퇴 버튼을 탭했을 때 호출됩니다.
    ///         회원탈퇴 화면으로 이동합니다.
    @objc
    private func userWithdrawButtonTapped() {
        let userWithdrawViewController = UserWithdrawViewController(nickName: nickName)
        navigationController?.pushViewController(userWithdrawViewController, animated: true)
    }

    // MARK: - Private Methods

    //======================================================================
    /// - Note: 테이블 뷰의 델리게이트와 데이터소스를 설정합니다.
    private func configureTableView() {
        mypageView.myPageTableView.dataSource = self
        mypageView.myPageTableView.delegate = self
    }

    /// - Note: Firebase와 연동되어 필요한 작업을 처리하거나, Analytics 이벤트를 전송합니다.
    ///         실제 서비스 시에만(디버그 모드 제외) 이벤트 로그를 전송합니다.
    private func setFirebaseTask() {
        FirebaseRemoteConfig.shared.fetchRestaurantInfo()

        #if !DEBUG
            Analytics.logEvent("MypageViewControllerLoad", parameters: nil)
        #endif
    }

    /// - Note: 로그아웃 알림창을 화면에 표시하고, 로그아웃 시에는 DB 초기화 및 로그인화면으로 전환합니다.
    private func showLogoutAlert() {
        AlertUtility.showConfirmAlert(
            title: "로그아웃",
            message: "정말 로그아웃 하시겠습니까?",
            confirmTitle: "로그아웃",
            cancelTitle: "취소",
            in: self
        ) {
            RealmService.shared.resetDB()

            let loginViewController = LoginViewController()
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
            {
                keyWindow.replaceRootViewController(
                    UINavigationController(rootViewController: loginViewController)
                )
            }
        }
    }

    /// - Note: UserDefaults에 푸시 알림 스위치 상태를 저장합니다.
    private func saveSwitchStateToUserDefaults() {
        #if DEBUG
            print("사용자 푸시 알림 값을 앱 저장소에 보관합니다.")
        #endif
        UserDefaults.standard.set(switchState, forKey: ESTextLiteral.MyPage.pushNotificationUserSettingKey)
    }

    /// - Note: UserDefaults에서 푸시 알림 스위치 상태를 불러옵니다.
    private func loadSwitchStateFromUserDefaults() {
        #if DEBUG
            print("사용자 푸시 알림 값을 앱 저장소에서 불러옵니다.")
        #endif
        switchState = UserDefaults.standard.bool(forKey: ESTextLiteral.MyPage.pushNotificationUserSettingKey)
    }
}

// MARK: - UITableViewDataSource

//======================================================================
extension MyPageViewController: UITableViewDataSource {
    /// - Note: 테이블 뷰의 섹션 당 셀 개수를 반환합니다.
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        myPageTableLabelList.count
    }

    /// - Note: 각 인덱스에 맞는 셀을 생성하여 반환합니다.
    ///         "푸시 알림 설정" 셀만 별도로 처리합니다.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // "푸시 알림 설정" 셀
        if indexPath.row == MyPageLabels.NotificationSetting.rawValue {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NotificationSettingTableViewCell.identifier,
                for: indexPath
            ) as? NotificationSettingTableViewCell else {
                return UITableViewCell()
            }

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
                    fatalError("지원하지 않는 알림 상태입니다.")
                }
            }
            return cell
        }

        // 기본 셀
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MyPageTableDefaultCell.identifier,
            for: indexPath
        ) as? MyPageTableDefaultCell else {
            return UITableViewCell()
        }
        cell.serviceLabel.text = myPageTableLabelList[indexPath.row].title
        return cell
    }
}

// MARK: - UITableViewDelegate

//======================================================================
extension MyPageViewController: UITableViewDelegate {
    /// - Note: 각 셀의 높이를 지정합니다.
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        60
    }

    /// - Note: 특정 셀을 탭했을 때의 동작을 정의합니다.
    ///         알림 설정, 리뷰 화면 이동, 문의하기, 약관/개인정보, 만든사람들, 로그아웃 등
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.row {
        // "푸시 알림 설정"
        case MyPageLabels.NotificationSetting.rawValue:
            NotificationManager.shared.checkNotificationSetting { setting in
                switch setting.authorizationStatus {
                case .denied:
                    DispatchQueue.main.async {
                        self.view.showToast(message: ESTextLiteral.MyPage.authorizeNotificationSettingMessage)
                    }
                default:
                    DispatchQueue.main.async {
                        guard let cell = tableView.cellForRow(at: indexPath) as? NotificationSettingTableViewCell else { return }
                        // 스위치 상태 반전
                        let newSwitchState = !self.switchState
                        cell.toggleSwitch.setOn(newSwitchState, animated: true)

                        // 스위치 상태 업데이트
                        self.switchState = newSwitchState

                        // 알림 수신 설정/해제 시간
                        let currentDate = Date()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                        let formattedDate = dateFormatter.string(from: currentDate)

                        if self.switchState {
                            #if DEBUG
                                print("푸시 알림을 발송합니다.")
                            #endif
                            NotificationManager.shared.scheduleWeekday11AMNotification()
                            self.view.showToast(message: "EAT-SSU 알림 수신을 동의하였습니다.\n(\(formattedDate))")
                        } else {
                            #if DEBUG
                                print("푸시 알림을 발송하지 않습니다.")
                            #endif
                            NotificationManager.shared.cancelWeekday11AMNotification()
                            self.view.showToast(message: "EAT-SSU 알림 수신을 거절하였습니다.\n(\(formattedDate))")
                        }
                        // UserDefaults에 상태 저장
                        self.saveSwitchStateToUserDefaults()
                    }
                }
            }

        // "내가 쓴 리뷰"
        case MyPageLabels.MyReview.rawValue:
            let myReviewViewController = MyReviewViewController()
            navigationController?.pushViewController(myReviewViewController, animated: true)

        // "문의하기"
        case MyPageLabels.Inquiry.rawValue:
            TalkApi.shared.chatChannel(channelPublicId: ESTextLiteral.KakaoChannel.id) { [weak self] error in
                if error != nil {
                    // 채널 연동 실패 시, 웹 브라우저로 연결
                    if let kakaoChannelLink = URL(string: "http://pf.kakao.com/\(ESTextLiteral.KakaoChannel.id)") {
                        UIApplication.shared.open(kakaoChannelLink)
                    } else {
                        self?.showAlertController(
                            title: "다시 시도하세요",
                            message: "에러가 발생했습니다",
                            style: .default
                        )
                    }
                } else {
                    // TODO: 카카오톡 채널 채팅방으로 연결 성공 시 필요한 로직
                }
            }

        // "서비스 이용약관"
        case MyPageLabels.TermsOfUse.rawValue:
            let provisionViewController = ProvisionViewController(agreementType: .termsOfService)
            provisionViewController.navigationTitle = ESTextLiteral.MyPage.termsOfUse
            navigationController?.pushViewController(provisionViewController, animated: true)

        // "개인정보 이용약관"
        case MyPageLabels.PrivacyTermsOfUse.rawValue:
            let provisionViewController = ProvisionViewController(agreementType: .privacyPolicy)
            provisionViewController.navigationTitle = ESTextLiteral.MyPage.privacyTermsOfUse
            navigationController?.pushViewController(provisionViewController, animated: true)

        // "만든사람들"
        case MyPageLabels.Creator.rawValue:
            let creatorViewController = CreatorViewController()
            navigationController?.pushViewController(creatorViewController, animated: true)

        // "로그아웃"
        case MyPageLabels.Logout.rawValue:
            showLogoutAlert()

        default:
            return
        }
    }
}
