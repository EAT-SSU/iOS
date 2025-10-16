//
//  SetNickNameViewController.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/04.
//

import UIKit

import Moya

import FirebaseAnalytics

import EATSSUDesign

enum SetNickNameSource {
    case signup   // 첫 로그인/회원가입 시
    case mypage   // 마이페이지-내 정보 시
}

final class SetNickNameViewController: BaseViewController {
    var source: SetNickNameSource = .signup
    // MARK: - Properties
    
    private let nicknameProvider = MoyaProvider<UserNicknameRouter>(session: Session(interceptor: AuthInterceptor.shared))
    private let myProvider = MoyaProvider<MyRouter>(session: Session(interceptor: AuthInterceptor.shared))
    private var originalNickname: String?
    private var originalDepartmentName: String?
    private var isNicknameChecked: Bool = false
    private var colleges: [LookupItemDTO] = []
    private var departments: [LookupItemDTO] = []

    // MARK: - UI Components
    
    private let setNickNameView = SetNickNameView()

    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboard()
        bindUI()
        fetchColleges()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNickNameView.setAccountInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let screenId: String
        switch source {
        case .signup:
            screenId = FirebaseScreenID.Login.log4
        case .mypage:
            screenId = FirebaseScreenID.MyPage.mypage3
        }
        
        logScreenView(screenID: screenId)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    // MARK: - UI Configuration

    override func configureUI() {
        view.addSubviews(setNickNameView)
    }

    override func setLayout() {
        setNickNameView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func setCustomNavigationBar() {
        super.setCustomNavigationBar()
        navigationItem.title = TextLiteral.setNickName
    }
    
    private func bindUI() {
        setNickNameView.completeSettingNickNameButton.addTarget(self, action: #selector(tappedCompleteNickNameButton), for: .touchUpInside)
        setNickNameView.nicknameDoubleCheckButton.addTarget(self, action: #selector(tappedCheckButton), for: .touchUpInside)
        setNickNameView.inputNickNameTextField.addTarget(self,
                                                         action: #selector(nicknameTextFieldDidChange),
                                                         for: .editingChanged)
        setNickNameView.onSelectCollege = { [weak self] collegeName in
            guard let self,
                  let id = self.colleges.first(where: { $0.name == collegeName })?.id
            else { return }
            self.fetchDepartments(collegeId: id)
            self.updateSaveButtonState()
        }
        setNickNameView.onSelectDepartment = { [weak self] _ in
            self?.updateSaveButtonState()
        }
    }

    // MARK: - @objc Methods
    
    @objc private func tappedCompleteNickNameButton() {
        let newNickname = setNickNameView.inputNickNameTextField.text ?? ""
        
        let hasNicknameChanged = newNickname != self.originalNickname
        let departmentChanged = isDepartmentChanged()
        
        guard hasNicknameChanged || departmentChanged else {
            print("변경된 정보가 없습니다.")
            view.showToast(message: "변경된 정보가 없습니다.")
            return
        }

        let dispatchGroup = DispatchGroup()
        var isNicknameUpdateSuccess = true
        var isDepartmentUpdateSuccess = true

        if hasNicknameChanged {
            dispatchGroup.enter()
            setUserNickname(newNickname) { success in
                isNicknameUpdateSuccess = success
                dispatchGroup.leave()
            }
        }

        if departmentChanged {
            guard let departmentName = setNickNameView.departmentDropDownView.getSelectedTitle(),
                  let departmentId = self.departments.first(where: { $0.name == departmentName })?.id else {
                print("유효하지 않은 학과 정보입니다.")
                return
            }
            let collegeName = setNickNameView.collegeDropDownView.getSelectedTitle()
            let collegeId = self.colleges.first(where: { $0.name == collegeName })?.id
           
            dispatchGroup.enter()
            setUserDepartment(departmentInfo: (id: departmentId, name: departmentName),
                             collegeInfo: (id: collegeId, name: collegeName)) { success in
                isDepartmentUpdateSuccess = success
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if isNicknameUpdateSuccess && isDepartmentUpdateSuccess {
                self.showCompletionAlert()
            } else {
                // 실패 시 사용자에게 알림
                self.showAlertController(title: "오류", message: "정보 업데이트 중 오류가 발생했습니다.", style: .cancel)
            }
        }
    }
    
    @objc private func nicknameTextFieldDidChange(_ textField: UITextField) {
        let newNickname = textField.text ?? ""
        let isNicknameChanged = (newNickname != originalNickname)
        
        if isNicknameChanged {
            self.isNicknameChecked = false
        }
        
        if newNickname.isEmpty {
            setNickNameView.nicknameValidationMessageLabel.text = NicknameTextFieldResultType.textFieldEmpty.hintMessage
            setNickNameView.nicknameValidationMessageLabel.textColor = NicknameTextFieldResultType.textFieldEmpty.textColor
            setNickNameView.nicknameDoubleCheckButton.isEnabled = false
        } else if !(2...8).contains(newNickname.count) {
            setNickNameView.nicknameValidationMessageLabel.text = NicknameTextFieldResultType.nicknameTextFieldOver.hintMessage
            setNickNameView.nicknameValidationMessageLabel.textColor = NicknameTextFieldResultType.nicknameTextFieldOver.textColor
            setNickNameView.nicknameDoubleCheckButton.isEnabled = false
        } else if isNicknameChanged {
            setNickNameView.nicknameValidationMessageLabel.text = NicknameTextFieldResultType.nicknameTextFieldDoubleCheck.hintMessage
            setNickNameView.nicknameValidationMessageLabel.textColor = NicknameTextFieldResultType.nicknameTextFieldDoubleCheck.textColor
            setNickNameView.nicknameDoubleCheckButton.isEnabled = true
        } else {
            setNickNameView.nicknameValidationMessageLabel.text = ""
            setNickNameView.nicknameDoubleCheckButton.isEnabled = false
        }
        
        updateSaveButtonState()
    }
    
    @objc
    private func tappedCheckButton() {
        checkNickname(nickname: setNickNameView.inputNickNameTextField.text ?? "")
    }
    
    // MARK: - Private Methods
    
    /// 학과 변경 여부를 명확하게 판단하는 헬퍼 메서드
    private func isDepartmentChanged() -> Bool {
        guard let selectedDepartment = setNickNameView.departmentDropDownView.getSelectedTitle(),
              selectedDepartment != "학과"
        else {
            return false
        }
        return selectedDepartment != originalDepartmentName
    }
    
    private func populateUIWithSavedData() {
        guard let userInfo = UserInfoManager.shared.getCurrentUserInfo() else { return }
            
        self.originalNickname = userInfo.nickname
        self.originalDepartmentName = userInfo.departmentName
                
        setNickNameView.inputNickNameTextField.text = userInfo.nickname
        setNickNameView.nicknameDoubleCheckButton.isEnabled = false
                
        if let collegeName = userInfo.collegeName,
           let collegeId = self.colleges.first(where: { $0.name == collegeName })?.id {
            setNickNameView.collegeDropDownView.setTitle(collegeName)
            
            fetchDepartments(collegeId: collegeId) { [weak self] in
                if let departmentName = userInfo.departmentName {
                    self?.setNickNameView.departmentDropDownView.setTitle(departmentName)
                    self?.updateSaveButtonState() // 학과 정보까지 로드 후 버튼 상태 최종 업데이트
                }
            }
        }
    }
    
    private func updateSaveButtonState() {
        let nicknameText = setNickNameView.inputNickNameTextField.text ?? ""

        // 조건 1: 닉네임 상태가 유효한가? (원래 닉네임이거나, 변경 후 중복 확인을 통과했거나)
        let isNicknameStateValid = (nicknameText == originalNickname) || isNicknameChecked
        
        // 조건 2: 무언가 변경되었는가? (닉네임이 다르거나, 학과가 다르거나)
        let hasNicknameChanged = (nicknameText != originalNickname)
        let departmentChanged = isDepartmentChanged()
        
        setNickNameView.completeSettingNickNameButton.isEnabled = isNicknameStateValid && (hasNicknameChanged || departmentChanged)
    }
    
    private func navigateToLogin() {
        let loginVC = LoginViewController()
        loginVC.toastMessage = "세션이 만료되었습니다. 다시 로그인해주세요."
        loginVC.toastType = .info
        
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                keyWindow.replaceRootViewController(UINavigationController(rootViewController: loginVC))
            }
        }
    }
}

// MARK: - Network
extension SetNickNameViewController {
    private func setUserNickname(_ nickname: String, completion: @escaping (Bool) -> Void) {
        nicknameProvider.request(.setNickname(nickname: nickname)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                if let user = UserInfoManager.shared.getCurrentUserInfo() {
                    UserInfoManager.shared.updateNickname(for: user, nickname: nickname)
                }
                completion(true)
            case .failure:
                RealmService.shared.resetDB()
                self.navigateToLogin()
                completion(false)
            }
        }
    }

    private func checkNickname(nickname: String) {
        nicknameProvider.request(.checkNickname(nickname: nickname)) { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let moyaResponse):
                do {
                    let responseData = try moyaResponse.map(BaseResponse<Bool>.self)
                    let isNicknameAvailable = responseData.result ?? false
                    
                    self.isNicknameChecked = isNicknameAvailable
                    
                    if isNicknameAvailable {
                        self.setNickNameView.nicknameValidationMessageLabel.text = "사용 가능한 닉네임이에요."
                        self.setNickNameView.nicknameValidationMessageLabel.textColor = EATSSUDesignAsset.Color.info.color
                    } else {
                        let resultType: NicknameTextFieldResultType = .nicknameTextFieldDuplicated
                        self.setNickNameView.nicknameValidationMessageLabel.text = resultType.hintMessage
                        self.setNickNameView.nicknameValidationMessageLabel.textColor = resultType.textColor
                    }
                    
                    self.setNickNameView.setNicknameChecked(isNicknameAvailable)
                    self.updateSaveButtonState()

                } catch let err {
                    print(err.localizedDescription)
                    
                    RealmService.shared.resetDB()
                    self.navigateToLogin()
                }
            case let .failure(err):
                print(err.localizedDescription)
                
                RealmService.shared.resetDB()
                self.navigateToLogin()
            }
        }
    }
    
    private func setUserDepartment(departmentInfo: (id: Int, name: String?), collegeInfo: (id: Int?, name: String?), completion: @escaping (Bool) -> Void) {
        nicknameProvider.request(.setDepartment(departmentId: departmentInfo.id)) { result in
            switch result {
            case .success:
                print("학과 등록 성공: ID \(departmentInfo.id)")
                if let user = UserInfoManager.shared.getCurrentUserInfo() {
                    UserInfoManager.shared.updateDepartment(for: user,
                                                            collegeId: collegeInfo.id,
                                                            collegeName: collegeInfo.name,
                                                            departmentId: departmentInfo.id,
                                                            departmentName: departmentInfo.name)
                }
                completion(true)
            case .failure(let error):
                print("학과 등록 실패: \(error.localizedDescription)")
                RealmService.shared.resetDB()
                self.navigateToLogin()
                completion(false)
            }
        }
    }
    
    private func fetchColleges() {
        myProvider.request(.colleges) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(res):
                do {
                   let decoded = try res.map(CollegesResponseDTO.self)
                   let list = decoded.result ?? []
                   self.colleges = list
                   self.setNickNameView.updateCollegeItems(list.map(\.name))
                   self.populateUIWithSavedData()
                } catch {
                    print("단과대 파싱 실패: \(error.localizedDescription)")
                }
            case let .failure(err):
                print("단과대 조회 실패: \(err.localizedDescription)")
            }
        }
    }

    private func fetchDepartments(collegeId: Int, completion: (() -> Void)? = nil) {
        myProvider.request(.departments(collegeId: collegeId)) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(res):
                do {
                    let decoded = try res.map(DepartmentsResponseDTO.self)
                    let list = decoded.result ?? []
                    self.departments = list
                    self.setNickNameView.updateDepartmentItems(list.map(\.name))
                    completion?()
                } catch {
                    print("학과 파싱 실패: \(error.localizedDescription)")
                    completion?()
                }
            case let .failure(err):
                print("학과 조회 실패: \(err.localizedDescription)")
                completion?()
            }
        }
    }
    
    private func showCompletionAlert() {
        self.showAlertController(title: "완료",
                                 message: "정보 수정이 완료되었습니다.",
                                 style: .cancel) {
            if let myPageVC = self.navigationController?
                .viewControllers
                .first(where: { $0 is MyPageViewController }) {
                self.navigationController?.popToViewController(myPageVC, animated: true)
            } else {
                let homeVC = HomeViewController()
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                    keyWindow.replaceRootViewController(
                        UINavigationController(rootViewController: homeVC)
                    )
                }
            }
        }
    }
}
