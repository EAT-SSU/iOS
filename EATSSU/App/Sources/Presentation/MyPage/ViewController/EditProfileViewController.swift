//
//  EditProfileViewController.swift
//  EATSSU
//
//  Created by Jiwoong CHOI on 01/31/25.
//

import RxSwift
import UIKit

import EATSSUKit

import AlertKit
import Moya

/**
 사용자의 닉네임을 설정 및 검증할 수 있는 화면을 관리하는 뷰 컨트롤러입니다.

 이 클래스는 사용자가 입력한 닉네임을 서버에 전송하여 설정하고, 중복 여부를 확인하는 API 요청을 수행합니다.
 또한, 사용자의 입력에 따라 UI를 업데이트하며, 닉네임 설정 완료 후 적절한 화면으로 전환합니다.

 ## 주요 기능
 - **닉네임 설정 API 요청**
   - `setUserNickname(nickname:)`: 사용자가 입력한 닉네임을 서버에 전송하여 저장합니다.
 - **닉네임 중복 확인 API 요청**
   - `checkNickname(nickname:)`: 사용자가 입력한 닉네임의 중복 여부를 확인합니다.
 - **UI 구성 및 이벤트 처리**
   - `EditProfileView`를 통해 사용자 정보 입력 및 닉네임 설정 UI를 구성합니다.
   - 닉네임 설정 완료 및 중복 확인 버튼의 이벤트를 처리합니다.
 - **네비게이션 및 화면 전환**
   - 닉네임 설정 완료 후 MyPage 혹은 Home 화면으로 전환합니다.

 ## 사용 예시
 ```swift
 let editProfileVC = EditProfileViewController()
 navigationController?.pushViewController(editProfileVC, animated: true)
 ```

 ## 관련 클래스 및 타입
 - `EditProfileView`: 사용자 정보 입력 및 닉네임 설정 UI를 담당하는 뷰
 - `UserNicknameRouter`: Moya를 사용한 닉네임 관련 API 요청 라우터
 - `UserInfoManager`: 사용자 정보를 관리하는 싱글턴 객체
 - `MyPageViewController`, `HomeViewController`: 화면 전환 시 사용되는 뷰 컨트롤러

 ## 주의사항
 - API 요청은 비동기로 처리되며, 네트워크 오류 발생 시 에러 메시지가 콘솔에 출력됩니다.
 - 닉네임 중복 확인 결과에 따라 UI의 상태(버튼 활성화, 레이블 색상 및 메시지)가 업데이트됩니다.
 */
final class EditProfileViewController: BaseViewController {
    // MARK: - Properties

    /// 닉네임 관련 API 요청을 위한 Moya Provider입니다.
    let nicknameProvider = MoyaProvider<UserNicknameRouter>(plugins: [ESMoyaLoggingPlugin()])

    let userDepartmentService = UserDepartmentService()
    private let disposeBag = DisposeBag()

    // MARK: - UI Components

    /// 사용자 정보 입력 및 닉네임 설정 UI를 포함하는 뷰입니다.
    let myInfoView = EditProfileView()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    // MARK: - UI 설정

    override func configureUI() {
        view.addSubviews(myInfoView)
    }

    override func setLayout() {
        myInfoView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func setESNavigationBar() {
        super.setESNavigationBar()
        navigationItem.title = ESTextLiteral.MyPage.myInfoTitle
    }

    override func setButtonEvent() {
        myInfoView.completeButton.addTarget(self, action: #selector(tappedCompleteNickNameButton), for: .touchUpInside)
        myInfoView.nicknameCheckButton.addTarget(self, action: #selector(tappedCheckButton), for: .touchUpInside)
    }

    // MARK: - 닉네임 설정 이벤트

    /// "닉네임 설정 완료" 버튼을 눌렀을 때 호출됩니다.
    @objc
    func tappedCompleteNickNameButton() {
        if let nickname = myInfoView.nicknameTextField.text, !nickname.isEmpty {
            setUserNickname(nickname: nickname)
        } else if let department = myInfoView.departmentTextField.text, !department.isEmpty {
            setUserDepartment(department: department)
        }
    }

    /// "중복 확인" 버튼을 눌렀을 때 호출됩니다.
    @objc
    func tappedCheckButton() {
        // 닉네임 값이 nil이거나 빈 문자열인 경우 추가 동작 수행
        guard let nickname = myInfoView.nicknameTextField.text, !nickname.isEmpty else {
            view.showToast(message: "닉네임을 입력해주세요")
            return
        }

        // 닉네임 값이 존재하면 API 요청 실행
        checkNickname(nickname: nickname)
    }
}

// MARK: - 네트워크 요청

extension EditProfileViewController {
    /// 사용자의 닉네임을 서버에 설정하는 API 요청을 보냅니다.
    /// - Parameter nickname: 사용자가 입력한 닉네임
    func setUserNickname(nickname: String) {
        nicknameProvider.request(.setNickname(nickname: nickname)) { response in
            switch response {
            case let .success(moyaResponse):
                do {
                    if let currentUserInfo = UserInfoManager.shared.getCurrentUserInfo() {
                        UserInfoManager.shared.updateNickname(for: currentUserInfo, nickname: nickname)
                    }
                    self.showAlertController(title: "완료", message: "닉네임 설정이 완료되었습니다", style: .cancel) {
                        if let myPageViewController = self.navigationController?.viewControllers.first(where: { $0 is MyPageViewController }) {
                            self.navigationController?.popToViewController(myPageViewController, animated: true)
                        } else {
                            let homeViewController = HomeViewController()
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
                            {
                                keyWindow.replaceRootViewController(UINavigationController(rootViewController: homeViewController))
                            }
                        }
                    }
                    #if DEBUG
                        print(moyaResponse.statusCode)
                    #endif
                    AlertControllerHelper.showConfirmOnlyAlert(title: "문제가 발생했습니다", message: "다시 시도하세요", in: self)
                }
            case let .failure(err):
                #if DEBUG
                    print(err.localizedDescription)
                #endif
                AlertControllerHelper.showConfirmOnlyAlert(title: "문제가 발생했습니다", message: "다시 시도하세요", in: self)
            }
        }
    }

    /// 사용자가 입력한 닉네임의 중복 여부를 확인하는 API 요청을 보냅니다.
    /// - Parameter nickname: 사용자가 입력한 닉네임
    func checkNickname(nickname: String) {
        nicknameProvider.request(.checkNickname(nickname: nickname)) { response in
            switch response {
            case let .success(moyaResponse):
                do {
                    let responseData = try moyaResponse.map(BaseResponse<Bool>.self)
                    let isSuccess = responseData.result
                    if isSuccess {
                        AlertKitAPI.present(
                            title: "사용가능한 닉네임이에요",
                            icon: .done,
                            style: .iOS17AppleMusic,
                            haptic: .success
                        )
                        self.myInfoView.completeButton.isEnabled = true
                        self.myInfoView.nicknameValidationLabel.text = NicknameTextFieldResultType.nicknameTextFieldValid.hintMessage
                        self.myInfoView.nicknameValidationLabel.textColor = NicknameTextFieldResultType.nicknameTextFieldValid.textColor
                    } else {
                        AlertKitAPI.present(
                            title: "이미 사용 중인 닉네임이에요",
                            icon: .error,
                            style: .iOS17AppleMusic,
                            haptic: .error
                        )
                        self.myInfoView.completeButton.isEnabled = false
                        self.myInfoView.nicknameValidationLabel.text =
                            NicknameTextFieldResultType.nicknameTextFieldDuplicated.hintMessage
                        self.myInfoView.nicknameValidationLabel.textColor =
                            NicknameTextFieldResultType.nicknameTextFieldDuplicated.textColor
                    }
                } catch let err {
                    #if DEBUG
                        print(err.localizedDescription)
                    #endif
                    AlertControllerHelper.showConfirmOnlyAlert(title: "문제가 발생했습니다", message: "다시 시도하세요", in: self)
                }
            case let .failure(err):
                #if DEBUG
                    print(err.localizedDescription)
                #endif
                AlertControllerHelper.showConfirmOnlyAlert(title: "문제가 발생했습니다", message: "다시 시도하세요", in: self)
            }
        }
    }

    func setUserDepartment(department: String) {
        userDepartmentService.addDepartment(departmentName: department)
            .subscribe(onSuccess: { [weak self] response in
                guard let self else { return }
                #if DEBUG
                    print("학과 변경 성공")
                    print(response)
                #endif

                showAlertController(title: "완료", message: "학과 설정이 완료되었습니다", style: .cancel) {
                    if let myPageViewController = self.navigationController?.viewControllers.first(where: { $0 is MyPageViewController }) {
                        self.navigationController?.popToViewController(myPageViewController, animated: true)
                    } else {
                        let homeViewController = HomeViewController()
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
                        {
                            keyWindow.replaceRootViewController(UINavigationController(rootViewController: homeViewController))
                        }
                    }
                }
            }, onFailure: { [weak self] error in
                guard let self else { return }
                #if DEBUG
                    print("학과 변경 실패")
                    print(error.localizedDescription)
                #endif
                AlertControllerHelper.showConfirmOnlyAlert(title: "문제가 발생했습니다", message: "다시 시도하세요", in: self)
            })
            .disposed(by: disposeBag)
    }
}
